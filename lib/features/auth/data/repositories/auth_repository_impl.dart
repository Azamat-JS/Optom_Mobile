import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:bsmart/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bsmart/features/auth/data/models/session_model.dart';
import 'package:bsmart/features/auth/domain/entities/auth_result.dart';
import 'package:bsmart/features/auth/domain/entities/session.dart';
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
  Future<Result<AuthResult>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    try {
      final (accessToken, refreshToken, user) = await _remote.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
      );
      final session = sessionFromTokens(accessToken: accessToken, refreshToken: refreshToken);
      await _local.saveSession(session);
      return Result.ok(AuthResult(session: session, user: user));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
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
