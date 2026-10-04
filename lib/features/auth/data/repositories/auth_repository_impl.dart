import 'package:dio/dio.dart';

import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:bsmart/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bsmart/features/auth/data/models/session_model.dart';
import 'package:bsmart/features/auth/data/models/user_model.dart';
import 'package:bsmart/features/auth/domain/entities/auth_result.dart';
import 'package:bsmart/features/auth/domain/entities/session.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_notification_settings.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_verification.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<AuthResult>> login({required String phone, required String password}) async {
    try {
      final (accessToken, refreshToken, user) = await _remote.login(phone: phone, password: password);
      final session = sessionFromTokens(accessToken: accessToken, refreshToken: refreshToken);
      await _local.saveSession(session);
      return Result.ok(AuthResult(session: session, user: user));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<TelegramNotificationSettings>> telegramNotifications({bool? enabled}) async {
    try {
      return Result.ok(await _remote.telegramNotifications(enabled: enabled));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<TelegramVerification>> startTelegramVerification(String phone) async {
    try {
      return Result.ok(await _remote.startTelegramVerification(phone));
    } on DioException catch (e) {
      // The backend's 429/503 texts are English; the generic mapper has no
      // case for either status, so give them Uzbek wording here.
      return Result.err(switch (e.response?.statusCode) {
        429 => const UnknownApiException(
            "Bu raqam uchun urinishlar juda ko'p. Birozdan so'ng qayta urinib ko'ring.",
          ),
        503 => const UnknownApiException(
            "Telegram orqali tasdiqlash vaqtincha ishlamayapti. Keyinroq urinib ko'ring.",
          ),
        400 => const ValidationApiException("Telefon raqam noto'g'ri. Format: +998XXXXXXXXX"),
        _ => mapDioException(e),
      });
    }
  }

  @override
  Future<Result<TelegramVerificationStatus>> pollTelegramVerification(TelegramVerification verification) async {
    try {
      final data = await _remote.pollTelegramVerification(
        verificationId: verification.verificationId,
        clientSecret: verification.clientSecret,
      );
      final TelegramVerificationStatus status = switch (data['status']) {
        'VERIFIED' => await _adoptVerifiedSession(data),
        'MISMATCH' => const TelegramMismatch(),
        'EXPIRED' => const TelegramExpired(),
        'CONSUMED' => const TelegramConsumed(),
        _ => const TelegramPending(),
      };
      return Result.ok(status);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  Future<TelegramVerified> _adoptVerifiedSession(Map<String, dynamic> data) async {
    final session = sessionFromTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    await _local.saveSession(session);
    final user = userFromJson(data['user'] as Map<String, dynamic>);
    return TelegramVerified(
      AuthResult(session: session, user: user),
      isNewUser: data['isNewUser'] == true,
    );
  }

  @override
  Future<Session?> restoreSession() => _local.restoreSession();

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final user = await _remote.getMe();
      return Result.ok(user);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? avatarUrl,
  }) async {
    try {
      final user = await _remote.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        currentPassword: currentPassword,
        newPassword: newPassword,
        avatarUrl: avatarUrl,
      );
      return Result.ok(user);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> verifyPassword(String password) async {
    try {
      await _remote.verifyPassword(password);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final refreshToken = await _local.readRefreshToken();
      if (refreshToken != null) {
        await _remote.logout(refreshToken);
      }
    } on DioException {
      // Best-effort — the local session is cleared regardless, since an
      // unreachable/erroring logout call shouldn't strand the user signed
      // in on this device.
    } finally {
      await _local.clear();
    }
    return const Result.ok(null);
  }
}
