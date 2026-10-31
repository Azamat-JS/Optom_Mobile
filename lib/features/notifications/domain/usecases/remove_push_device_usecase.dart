import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/notifications/domain/repositories/notifications_repository.dart';

class RemovePushDeviceUseCase {
  RemovePushDeviceUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<void>> call(String token) => _repository.removePushDevice(token);
}
