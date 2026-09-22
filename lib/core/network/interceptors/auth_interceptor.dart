import 'package:dio/dio.dart';

import 'package:bsmart/core/storage/secure_token_storage.dart';

/// Attaches `Authorization: Bearer <token>` to every request except the
/// unauthenticated `/auth/login` and `/auth/refresh` calls.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final SecureTokenStorage _tokenStorage;

  static const _skipPaths = {'/auth/login', '/auth/refresh'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_skipPaths.any(options.path.contains)) {
      handler.next(options);
      return;
    }
    final token = await _tokenStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
