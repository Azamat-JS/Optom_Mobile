import 'dart:async';

import 'package:dio/dio.dart';

import 'package:bsmart/core/network/auth_event_bus.dart';
import 'package:bsmart/core/storage/secure_token_storage.dart';

/// Handles 401s with single-flight refresh: concurrent 401s all await the
/// same in-flight `/auth/refresh` call (via [_refreshCompleter]) instead of
/// each firing their own refresh request, then retry with the new token.
///
/// [bareDio] must carry none of these interceptors — calling `/auth/refresh`
/// through [mainDio] would recurse back into this same handler.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required Dio mainDio,
    required Dio bareDio,
    required SecureTokenStorage tokenStorage,
    required AuthEventBus eventBus,
  })  : _mainDio = mainDio,
        _bareDio = bareDio,
        _tokenStorage = tokenStorage,
        _eventBus = eventBus;

  final Dio _mainDio;
  final Dio _bareDio;
  final SecureTokenStorage _tokenStorage;
  final AuthEventBus _eventBus;

  Completer<String?>? _refreshCompleter;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isAuthPath = options.path.contains('/auth/login') || options.path.contains('/auth/refresh');
    final alreadyRetried = options.extra['bsmartRetried'] == true;

    if (err.response?.statusCode != 401 || isAuthPath || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      await _tokenStorage.clear();
      _eventBus.emitForceLogout();
      handler.next(err);
      return;
    }

    options.extra['bsmartRetried'] = true;
    options.headers['Authorization'] = 'Bearer $newAccessToken';
    try {
      final retried = await _mainDio.fetch<dynamic>(options);
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<String?> _refreshAccessToken() {
    final existing = _refreshCompleter;
    if (existing != null) return existing.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;
    _performRefresh().then(completer.complete).whenComplete(() => _refreshCompleter = null);
    return completer.future;
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _bareDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data!;
      final accessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;
      await _tokenStorage.saveTokens(accessToken: accessToken, refreshToken: newRefreshToken);
      return accessToken;
    } on DioException {
      return null;
    }
  }
}
