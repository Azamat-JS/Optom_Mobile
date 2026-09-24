import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_query.dart';
import 'package:bsmart/features/platform_users/domain/usecases/list_platform_users_usecase.dart';

class PlatformUsersListState {
  const PlatformUsersListState({
    required this.items,
    required this.query,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<PlatformUser> items;
  final PlatformUserQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  PlatformUsersListState copyWith({
    List<PlatformUser>? items,
    PlatformUserQuery? query,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return PlatformUsersListState(
      items: items ?? this.items,
      query: query ?? this.query,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Paginated + filterable — the same notifier backs every SUPER_ADMIN
/// "management" list (wholesalers, each retailer vertical, customers) via
/// [setRole]/[setBusinessType]/[search], never a per-role notifier.
class PlatformUsersListNotifier extends AsyncNotifier<PlatformUsersListState> {
  @override
  Future<PlatformUsersListState> build() => _fetch(const PlatformUserQuery());

  Future<PlatformUsersListState> _fetch(PlatformUserQuery query) async {
    final result = await getIt<ListPlatformUsersUseCase>().call(query);
    return result.fold(
      (page) => PlatformUsersListState(items: page.data, query: query, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull?.query ?? const PlatformUserQuery();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1)));
  }

  Future<void> setRole(UserRole? role) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(PlatformUserQuery(role: role, page: 1)),
    );
  }

  Future<void> setBusinessType(BusinessType? businessType) async {
    final current = state.valueOrNull?.query ?? const PlatformUserQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(businessType: businessType, clearBusinessType: businessType == null, page: 1)),
    );
  }

  Future<void> search(String? query) async {
    final current = state.valueOrNull?.query ?? const PlatformUserQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(search: query, page: 1)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextQuery = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListPlatformUsersUseCase>().call(nextQuery);
    state = result.fold(
      (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.data],
          query: nextQuery,
          hasNext: page.meta.hasNext,
          isLoadingMore: false,
        ),
      ),
      (failure) => AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }
}

final platformUsersListProvider = AsyncNotifierProvider<PlatformUsersListNotifier, PlatformUsersListState>(
  PlatformUsersListNotifier.new,
);
