import 'package:dio/dio.dart';

import 'package:bsmart/features/auth/data/models/user_model.dart';
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
