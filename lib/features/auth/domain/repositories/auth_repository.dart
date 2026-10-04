import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/auth_result.dart';
import 'package:bsmart/features/auth/domain/entities/session.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_notification_settings.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_verification.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';

/// Presentation and other domain layers depend on this abstraction, never on
/// [AuthRepositoryImpl] directly (SOLID's Dependency Inversion) — `get_it`
/// is what resolves which implementation a caller actually receives.
abstract class AuthRepository {
  Future<Result<AuthResult>> login({required String phone, required String password});

  /// Passwordless register + login in one flow: the user confirms [phone] by
  /// sharing their own Telegram contact with the verify bot. An existing
  /// account is logged in; otherwise a new `CUSTOMER` account is created.
  Future<Result<TelegramVerification>> startTelegramVerification(String phone);

  /// One poll of a started verification. On [TelegramVerified] the session
  /// has already been saved to secure storage.
  Future<Result<TelegramVerificationStatus>> pollTelegramVerification(TelegramVerification verification);

  /// Delivery notifications via the verify bot; [enabled] null = just read.
  Future<Result<TelegramNotificationSettings>> telegramNotifications({bool? enabled});

  /// Restores a session from secure storage on app cold-start, if a valid
  /// (non-expired, by claim) access token exists. Does not hit the network.
  Future<Session?> restoreSession();

  Future<Result<User>> getCurrentUser();

  Future<Result<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? avatarUrl,
  });

  Future<Result<void>> verifyPassword(String password);

  Future<Result<void>> logout();
}
