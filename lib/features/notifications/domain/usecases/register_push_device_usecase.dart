import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/notifications/domain/repositories/notifications_repository.dart';

class RegisterPushDeviceUseCase {
  RegisterPushDeviceUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<Result<void>> call({required String token, required String platform, required String locale}) =>
      _repository.registerPushDevice(token: token, platform: platform, locale: locale);
}
