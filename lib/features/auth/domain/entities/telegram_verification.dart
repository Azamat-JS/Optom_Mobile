import 'package:bsmart/features/auth/domain/entities/auth_result.dart';

/// A started "Telegram orqali davom etish" request (`POST /auth/telegram/start`).
///
/// [clientSecret] is only ever held in memory by this device — the backend
/// stores just its hash and refuses to answer a poll without it, so the
/// deep link alone ([botUrl], which the user opens in Telegram) can never be
/// used to pick up the resulting session.
class TelegramVerification {
  const TelegramVerification({
    required this.verificationId,
    required this.clientSecret,
    required this.botUrl,
    required this.botUsername,
    required this.expiresAt,
  });

  final String verificationId;
  final String clientSecret;
  final String botUrl;
  final String botUsername;
  final DateTime expiresAt;
}

/// One `POST /auth/telegram/poll` answer.
sealed class TelegramVerificationStatus {
  const TelegramVerificationStatus();
}

/// The user hasn't shared their contact in the bot yet.
final class TelegramPending extends TelegramVerificationStatus {
  const TelegramPending();
}

/// The Telegram account's number differs from the one typed in the app.
final class TelegramMismatch extends TelegramVerificationStatus {
  const TelegramMismatch();
}

/// The 10-minute window passed without a shared contact.
final class TelegramExpired extends TelegramVerificationStatus {
  const TelegramExpired();
}

/// The session for this request was already handed out (another poll won).
final class TelegramConsumed extends TelegramVerificationStatus {
  const TelegramConsumed();
}

/// Verified — the session is already saved to secure storage by the repository.
/// [isNewUser] is true when this verification created a new CUSTOMER account.
final class TelegramVerified extends TelegramVerificationStatus {
  const TelegramVerified(this.authResult, {required this.isNewUser});

  final AuthResult authResult;
  final bool isNewUser;
}
