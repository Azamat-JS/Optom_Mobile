import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/notifications/domain/repositories/notifications_repository.dart';

class GetUnreadNotificationCountUseCase {
  GetUnreadNotificationCountUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<int>> call() => _repository.unreadCount();
}
