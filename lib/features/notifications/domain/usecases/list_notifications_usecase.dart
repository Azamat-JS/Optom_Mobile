import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/notifications/domain/entities/app_notification.dart';
import 'package:bsmart/features/notifications/domain/repositories/notifications_repository.dart';

class ListNotificationsUseCase {
  ListNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<NotificationPage>> call({int page = 1, int limit = 20}) => _repository.list(page: page, limit: limit);
}
