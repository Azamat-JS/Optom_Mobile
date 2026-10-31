import 'package:dio/dio.dart';

import 'package:bsmart/features/notifications/data/models/app_notification_model.dart';
import 'package:bsmart/features/notifications/domain/entities/app_notification.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<NotificationPage> list({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    return notificationPageFromJson(response.data!);
  }

  Future<int> unreadCount() async {
    final response = await _dio.get<Map<String, dynamic>>('/notifications/unread-count');
    return (response.data!['count'] as num).toInt();
  }

  Future<void> markRead(String id) => _dio.patch<void>('/notifications/$id/read');

  Future<void> markAllRead() => _dio.post<void>('/notifications/read-all');

  /// Binds this phone's FCM token to the signed-in user (C7). [platform] is `ANDROID` / `IOS`.
  Future<void> registerPushDevice({required String token, required String platform, required String locale}) =>
      _dio.put<void>('/notifications/push-devices', data: {'token': token, 'platform': platform, 'locale': locale});

  Future<void> removePushDevice(String token) =>
      _dio.post<void>('/notifications/push-devices/remove', data: {'token': token});
}
