import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/active_store/presentation/active_store_notifier.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';
import 'package:bsmart/features/crm/domain/usecases/get_crm_driver_telegram_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/get_crm_driver_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/list_crm_drivers_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/list_crm_reminders_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/list_crm_visits_usecase.dart';
import 'package:bsmart/features/crm/domain/usecases/update_crm_reminder_usecase.dart';

T _unwrap<T>(Result<T> result) => result.fold((value) => value, (failure) => throw failure);

// Every CRM list is store-scoped server-side, so each provider watches the active store and the
// signed-in user: switching branches or accounts reloads it.

class CrmDriversListState {
  const CrmDriversListState({required this.items, required this.query, this.hasNext = false, this.isLoadingMore = false});

  final List<CrmDriver> items;
  final CrmDriverQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  CrmDriversListState copyWith({List<CrmDriver>? items, CrmDriverQuery? query, bool? hasNext, bool? isLoadingMore}) =>
      CrmDriversListState(
        items: items ?? this.items,
        query: query ?? this.query,
        hasNext: hasNext ?? this.hasNext,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class CrmDriversListNotifier extends AsyncNotifier<CrmDriversListState> {
  @override
  Future<CrmDriversListState> build() {
    ref.watch(currentUserIdProvider);
    ref.watch(activeStoreNotifierProvider);
    return _fetch(const CrmDriverQuery());
  }

  Future<CrmDriversListState> _fetch(CrmDriverQuery query) async {
    final page = _unwrap(await getIt<ListCrmDriversUseCase>().call(query));
    return CrmDriversListState(items: page.data, query: query, hasNext: page.meta.hasNext);
  }

  CrmDriverQuery get _query => state.valueOrNull?.query ?? const CrmDriverQuery();

  Future<void> refresh() async => state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1)));

  Future<void> search(String text) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1, search: text)));
  }

  /// true = active, false = inactive, null = all.
  Future<void> setActiveFilter(bool? activeOnly) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(_query.copyWith(page: 1, activeOnly: activeOnly, clearActive: activeOnly == null)),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final next = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListCrmDriversUseCase>().call(next);
    state = AsyncData(
      result.fold(
        (page) => current.copyWith(items: [...current.items, ...page.data], query: next, hasNext: page.meta.hasNext, isLoadingMore: false),
        (_) => current.copyWith(isLoadingMore: false),
      ),
    );
  }
}

final crmDriversListProvider = AsyncNotifierProvider<CrmDriversListNotifier, CrmDriversListState>(
  CrmDriversListNotifier.new,
);

final crmDriverProvider = FutureProvider.autoDispose.family<CrmDriver, String>((ref, id) async {
  return _unwrap(await getIt<GetCrmDriverUseCase>().call(id));
});

/// Whether the store's bot can message the driver; reloaded when the driver (e.g. their phone)
/// changes because the detail screen invalidates it.
final crmDriverTelegramProvider = FutureProvider.autoDispose.family<CrmTelegramStatus, String>((ref, id) async {
  return _unwrap(await getIt<GetCrmDriverTelegramUseCase>().call(id));
});

class CrmVisitsState {
  const CrmVisitsState({required this.items, required this.page, required this.hasNext, this.isLoadingMore = false});

  final List<CrmVisit> items;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;
}

/// A driver's service history, newest first, 10 at a time.
class CrmVisitsNotifier extends AutoDisposeFamilyAsyncNotifier<CrmVisitsState, String> {
  static const _limit = 10;

  @override
  Future<CrmVisitsState> build(String driverId) async {
    final page = _unwrap(await getIt<ListCrmVisitsUseCase>().call(driverId: driverId, limit: _limit));
    return CrmVisitsState(items: page.data, page: 1, hasNext: page.meta.hasNext);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(CrmVisitsState(items: current.items, page: current.page, hasNext: true, isLoadingMore: true));
    final result = await getIt<ListCrmVisitsUseCase>().call(driverId: arg, page: current.page + 1, limit: _limit);
    state = AsyncData(
      result.fold(
        (page) => CrmVisitsState(items: [...current.items, ...page.data], page: current.page + 1, hasNext: page.meta.hasNext),
        (_) => current,
      ),
    );
  }
}

final crmVisitsProvider = AsyncNotifierProvider.autoDispose.family<CrmVisitsNotifier, CrmVisitsState, String>(
  CrmVisitsNotifier.new,
);

class CrmRemindersState {
  const CrmRemindersState({
    required this.items,
    required this.query,
    required this.overdueCount,
    required this.soonCount,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<CrmReminder> items;
  final CrmReminderQuery query;
  final int overdueCount;
  final int soonCount;
  final bool hasNext;
  final bool isLoadingMore;

  CrmRemindersState copyWith({List<CrmReminder>? items, CrmReminderQuery? query, bool? hasNext, bool? isLoadingMore}) =>
      CrmRemindersState(
        items: items ?? this.items,
        query: query ?? this.query,
        overdueCount: overdueCount,
        soonCount: soonCount,
        hasNext: hasNext ?? this.hasNext,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// Active reminders of the active store, soonest first, with the overdue / 7-day tab counts.
class CrmRemindersNotifier extends AsyncNotifier<CrmRemindersState> {
  @override
  Future<CrmRemindersState> build() {
    ref.watch(currentUserIdProvider);
    ref.watch(activeStoreNotifierProvider);
    return _fetch(const CrmReminderQuery());
  }

  Future<CrmRemindersState> _fetch(CrmReminderQuery query) async {
    final result = _unwrap(await getIt<ListCrmRemindersUseCase>().call(query));
    return CrmRemindersState(
      items: result.page.data,
      query: query,
      overdueCount: result.overdueCount,
      soonCount: result.soonCount,
      hasNext: result.page.meta.hasNext,
    );
  }

  CrmReminderQuery get _query => state.valueOrNull?.query ?? const CrmReminderQuery();

  Future<void> refresh() async => state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1)));

  Future<void> setWhen(CrmReminderWhen when) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1, when: when)));
  }

  Future<void> search(String text) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1, search: text)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final next = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListCrmRemindersUseCase>().call(next);
    state = AsyncData(
      result.fold(
        (r) => current.copyWith(items: [...current.items, ...r.page.data], query: next, hasNext: r.page.meta.hasNext, isLoadingMore: false),
        (_) => current.copyWith(isLoadingMore: false),
      ),
    );
  }

  /// Done / cancelled / a new date; reloads the list (and its counts). Throws the API failure.
  Future<void> changeReminder(String id, {CrmItemStatus? status, DateTime? dueDate}) async {
    _unwrap(await getIt<UpdateCrmReminderUseCase>().call(id, status: status, dueDate: dueDate));
    await refresh();
  }
}

final crmRemindersProvider = AsyncNotifierProvider<CrmRemindersNotifier, CrmRemindersState>(CrmRemindersNotifier.new);
