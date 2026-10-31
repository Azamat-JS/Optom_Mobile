import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:bsmart/features/notifications/domain/entities/app_notification.dart';
import 'package:bsmart/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.ok(await call());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<NotificationPage>> list({int page = 1, int limit = 20}) =>
      _guard(() => _remote.list(page: page, limit: limit));

  @override
  Future<Result<int>> unreadCount() => _guard(_remote.unreadCount);

  @override
  Future<Result<void>> markRead(String id) => _guard(() => _remote.markRead(id));

  @override
  Future<Result<void>> markAllRead() => _guard(_remote.markAllRead);

  @override
  Future<Result<void>> registerPushDevice({required String token, required String platform, required String locale}) =>
      _guard(() => _remote.registerPushDevice(token: token, platform: platform, locale: locale));

  @override
  Future<Result<void>> removePushDevice(String token) => _guard(() => _remote.removePushDevice(token));
}
