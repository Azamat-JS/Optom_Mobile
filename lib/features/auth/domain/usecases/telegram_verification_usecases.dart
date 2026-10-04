import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_notification_settings.dart';
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

/// Read ([enabled] null) or switch the verify bot's delivery notifications (Phase 7 N3).
class TelegramNotificationsUseCase {
  TelegramNotificationsUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<TelegramNotificationSettings>> call({bool? enabled}) =>
      _repository.telegramNotifications(enabled: enabled);
}
