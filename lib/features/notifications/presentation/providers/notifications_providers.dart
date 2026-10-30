import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/notifications/domain/entities/app_notification.dart';
import 'package:bsmart/features/notifications/domain/usecases/get_unread_notification_count_usecase.dart';
import 'package:bsmart/features/notifications/domain/usecases/list_notifications_usecase.dart';
import 'package:bsmart/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:bsmart/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

/// The bell's badge. Refreshed by the bell (on show, every minute, on app resume) and corrected
/// by the inbox screen whenever it loads a page. A failed refresh keeps the last value.
class UnreadNotificationsNotifier extends Notifier<int> {
  @override
  int build() {
    ref.watch(currentUserIdProvider);
    return 0;
  }

  Future<void> refresh() async {
    if (ref.read(currentUserIdProvider) == null) return;
    final result = await getIt<GetUnreadNotificationCountUseCase>().call();
    result.fold((count) => state = count, (_) {});
  }

  void set(int count) => state = count < 0 ? 0 : count;
}

final unreadNotificationsProvider = NotifierProvider<UnreadNotificationsNotifier, int>(UnreadNotificationsNotifier.new);

class NotificationsState {
  const NotificationsState({required this.items, required this.page, required this.hasNext, this.isLoadingMore = false});

  final List<AppNotification> items;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  NotificationsState copyWith({List<AppNotification>? items, int? page, bool? hasNext, bool? isLoadingMore}) =>
      NotificationsState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasNext: hasNext ?? this.hasNext,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// The inbox, newest first, 20 at a time.
class NotificationsNotifier extends AutoDisposeAsyncNotifier<NotificationsState> {
  @override
  Future<NotificationsState> build() async {
    ref.watch(currentUserIdProvider);
    final page = (await getIt<ListNotificationsUseCase>().call()).fold((p) => p, (f) => throw f);
    ref.read(unreadNotificationsProvider.notifier).set(page.unread);
    return NotificationsState(items: page.items, page: 1, hasNext: page.hasNext);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<ListNotificationsUseCase>().call(page: current.page + 1);
    state = AsyncData(
      result.fold(
        (p) => current.copyWith(items: [...current.items, ...p.items], page: current.page + 1, hasNext: p.hasNext, isLoadingMore: false),
        (_) => current.copyWith(isLoadingMore: false),
      ),
    );
  }

  /// Optimistic: the row and the badge change at once; the request runs in the background.
  void markRead(AppNotification n) {
    if (n.isRead) return;
    final current = state.valueOrNull;
    if (current != null) {
      final now = DateTime.now();
      state = AsyncData(current.copyWith(items: [for (final x in current.items) x.id == n.id ? x.markedRead(now) : x]));
    }
    final unread = ref.read(unreadNotificationsProvider);
    ref.read(unreadNotificationsProvider.notifier).set(unread - 1);
    getIt<MarkNotificationReadUseCase>().call(n.id);
  }

  Future<void> markAllRead() async {
    final result = await getIt<MarkAllNotificationsReadUseCase>().call();
    result.fold((_) {
      final current = state.valueOrNull;
      final now = DateTime.now();
      if (current != null) state = AsyncData(current.copyWith(items: [for (final x in current.items) x.markedRead(now)]));
      ref.read(unreadNotificationsProvider.notifier).set(0);
    }, (f) => throw f);
  }
}

final notificationsProvider = AsyncNotifierProvider.autoDispose<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
