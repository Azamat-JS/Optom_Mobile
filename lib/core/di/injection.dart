import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:bsmart/core/network/auth_event_bus.dart';
import 'package:bsmart/core/network/dio_client.dart';
import 'package:bsmart/core/storage/active_store_storage.dart';
import 'package:bsmart/core/storage/secure_token_storage.dart';
import 'package:bsmart/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:bsmart/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bsmart/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';
import 'package:bsmart/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/login_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/verify_password_usecase.dart';

const _bareDioInstance = 'bareDio';
const _mainDioInstance = 'mainDio';

/// The app's dependency graph, wired manually (not `injectable` code-gen —
/// see the implementation plan's note on keeping the first milestone's
/// moving parts minimal; can be migrated to annotation-driven registration
/// later without touching call sites, since everything is still resolved
/// through this one [GetIt] instance).
///
/// Riverpod providers are the only consumers of [getIt] — object-graph
/// construction lives here, reactive UI state lives in Riverpod notifiers.
final getIt = GetIt.instance;

void setupDependencyInjection() {
  // --- Core / cross-cutting ---
  getIt.registerLazySingleton(() => AuthEventBus());
  getIt.registerLazySingleton(() => SecureTokenStorage());
  getIt.registerLazySingleton(() => ActiveStoreStorage());

  getIt.registerLazySingleton<Dio>(createBareDio, instanceName: _bareDioInstance);
  getIt.registerLazySingleton<Dio>(
    () => createMainDio(
      bareDio: getIt<Dio>(instanceName: _bareDioInstance),
      tokenStorage: getIt<SecureTokenStorage>(),
      activeStoreStorage: getIt<ActiveStoreStorage>(),
      eventBus: getIt<AuthEventBus>(),
    ),
    instanceName: _mainDioInstance,
  );

  // --- features/auth ---
  getIt.registerLazySingleton(() => AuthRemoteDataSource(getIt<Dio>(instanceName: _mainDioInstance)));
  getIt.registerLazySingleton(() => AuthLocalDataSource(getIt<SecureTokenStorage>()));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt(), local: getIt()),
  );
  getIt.registerFactory(() => LoginUseCase(getIt()));
  getIt.registerFactory(() => LogoutUseCase(getIt()));
  getIt.registerFactory(() => GetCurrentUserUseCase(getIt()));
  getIt.registerFactory(() => UpdateProfileUseCase(getIt()));
  getIt.registerFactory(() => VerifyPasswordUseCase(getIt()));
}

/// The main authenticated [Dio] instance — for feature data sources
/// registered outside this file (e.g. future `products`/`orders` modules).
Dio get mainDio => getIt<Dio>(instanceName: _mainDioInstance);
