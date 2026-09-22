import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:bsmart/core/config/env.dart';
import 'package:bsmart/core/network/auth_event_bus.dart';
import 'package:bsmart/core/network/interceptors/active_store_interceptor.dart';
import 'package:bsmart/core/network/interceptors/auth_interceptor.dart';
import 'package:bsmart/core/network/interceptors/refresh_interceptor.dart';
import 'package:bsmart/core/storage/active_store_storage.dart';
import 'package:bsmart/core/storage/secure_token_storage.dart';

/// Interceptor-free — used only by [RefreshInterceptor] to call
/// `/auth/refresh` and by the public-catalog feature (Phase 2) that needs no
/// auth header at all.
Dio createBareDio() {
  return Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
}

/// The main authenticated client every feature's remote data source uses.
Dio createMainDio({
  required Dio bareDio,
  required SecureTokenStorage tokenStorage,
  required ActiveStoreStorage activeStoreStorage,
  required AuthEventBus eventBus,
}) {
  final dio = createBareDio();
  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage),
    ActiveStoreInterceptor(activeStoreStorage),
    RefreshInterceptor(
      mainDio: dio,
      bareDio: bareDio,
      tokenStorage: tokenStorage,
      eventBus: eventBus,
    ),
    if (kDebugMode)
      PrettyDioLogger(requestBody: true, responseBody: true, error: true),
  ]);
  return dio;
}
