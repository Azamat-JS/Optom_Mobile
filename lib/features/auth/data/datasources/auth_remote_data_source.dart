import 'package:dio/dio.dart';

import 'package:bsmart/features/auth/data/models/user_model.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_verification.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';

/// Raw calls against `/auth/*`. Returns plain JSON maps / tokens — mapping
/// into domain entities happens one layer up, in [AuthRepositoryImpl].
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// Returns `(accessToken, refreshToken, user)`.
  Future<(String, String, User)> login({required String phone, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    final data = response.data!;
    return (
      data['accessToken'] as String,
      data['refreshToken'] as String,
      userFromJson(data['user'] as Map<String, dynamic>),
    );
  }

  /// `POST /auth/telegram/start` — opens a verification for [phone] and
  /// returns the bot deep link plus the client secret needed to poll it.
  Future<TelegramVerification> startTelegramVerification(String phone) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/telegram/start', data: {'phone': phone});
    final data = response.data!;
    return TelegramVerification(
      verificationId: data['verificationId'] as String,
      clientSecret: data['clientSecret'] as String,
      botUrl: data['botUrl'] as String,
      botUsername: data['botUsername'] as String,
      expiresAt: DateTime.parse(data['expiresAt'] as String),
    );
  }

  /// `POST /auth/telegram/poll` — returns the raw body: `{status}` and, for
  /// `VERIFIED` only (exactly once), the same token/user payload as login
  /// plus `isNewUser`.
  Future<Map<String, dynamic>> pollTelegramVerification({
    required String verificationId,
    required String clientSecret,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/telegram/poll',
      data: {'verificationId': verificationId, 'clientSecret': clientSecret},
    );
    return response.data!;
  }

  Future<User> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return userFromJson(response.data!);
  }

  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? avatarUrl,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/auth/me',
      data: {
        'firstName': ?firstName,
        'lastName': ?lastName,
        'phone': ?phone,
        'currentPassword': ?currentPassword,
        'newPassword': ?newPassword,
        'avatarUrl': ?avatarUrl,
      },
    );
    return userFromJson(response.data!);
  }

  Future<void> verifyPassword(String password) {
    return _dio.post<void>('/auth/verify-password', data: {'password': password});
  }

  Future<void> logout(String refreshToken) {
    return _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
  }
}
