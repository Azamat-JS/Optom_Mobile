import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_verification.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';

class StartTelegramVerificationUseCase {
  StartTelegramVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<TelegramVerification>> call(String phone) => _repository.startTelegramVerification(phone);
}

class PollTelegramVerificationUseCase {
  PollTelegramVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<TelegramVerificationStatus>> call(TelegramVerification verification) =>
      _repository.pollTelegramVerification(verification);
}
