import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/notifications/domain/entities/app_notification.dart';

/// `/notifications` — the caller's own inbox, any role.
abstract class NotificationsRepository {
  Future<Result<NotificationPage>> list({int page = 1, int limit = 20});

  Future<Result<int>> unreadCount();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();
}
