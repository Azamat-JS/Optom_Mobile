import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  MarkNotificationReadUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<void>> call(String id) => _repository.markRead(id);
}
