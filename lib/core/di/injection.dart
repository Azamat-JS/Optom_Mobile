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
import 'package:bsmart/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:bsmart/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:bsmart/features/categories/domain/repositories/categories_repository.dart';
import 'package:bsmart/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:bsmart/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:bsmart/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:bsmart/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:bsmart/features/catalog/domain/usecases/browse_catalog_usecase.dart';
import 'package:bsmart/features/catalog/domain/usecases/list_catalog_sellers_usecase.dart';
import 'package:bsmart/features/catalog/domain/usecases/list_seller_stores_usecase.dart';
import 'package:bsmart/features/dashboard/data/datasources/reporting_remote_data_source.dart';
import 'package:bsmart/features/dashboard/data/repositories/reporting_repository_impl.dart';
import 'package:bsmart/features/dashboard/domain/repositories/reporting_repository.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_income_debt_chart_usecase.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_retailer_dashboard_usecase.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_wholesaler_dashboard_usecase.dart';
import 'package:bsmart/features/master_catalog/data/datasources/master_catalog_remote_data_source.dart';
import 'package:bsmart/features/master_catalog/data/repositories/master_catalog_repository_impl.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/search_master_catalog_usecase.dart';
import 'package:bsmart/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:bsmart/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:bsmart/features/orders/domain/repositories/orders_repository.dart';
import 'package:bsmart/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:bsmart/features/orders/domain/usecases/get_order_usecase.dart';
import 'package:bsmart/features/orders/domain/usecases/list_orders_usecase.dart';
import 'package:bsmart/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:bsmart/features/products/data/datasources/products_remote_data_source.dart';
import 'package:bsmart/features/products/data/repositories/products_repository_impl.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';
import 'package:bsmart/features/products/domain/usecases/assign_barcode_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/create_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/delete_product_image_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/get_next_plu_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/get_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/receive_stock_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/share_to_catalog_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/update_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/upload_product_image_usecase.dart';

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

  // --- features/categories ---
  getIt.registerLazySingleton(() => CategoriesRemoteDataSource(mainDio));
  getIt.registerLazySingleton<CategoriesRepository>(() => CategoriesRepositoryImpl(getIt()));
  getIt.registerFactory(() => GetCategoriesUseCase(getIt()));

  // --- features/products ---
  getIt.registerLazySingleton(() => ProductsRemoteDataSource(mainDio));
  getIt.registerLazySingleton<ProductsRepository>(() => ProductsRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListProductsUseCase(getIt()));
  getIt.registerFactory(() => GetProductUseCase(getIt()));
  getIt.registerFactory(() => CreateProductUseCase(getIt()));
  getIt.registerFactory(() => UpdateProductUseCase(getIt()));
  getIt.registerFactory(() => DeleteProductUseCase(getIt()));
  getIt.registerFactory(() => ReceiveStockUseCase(getIt()));
  getIt.registerFactory(() => AssignBarcodeUseCase(getIt()));
  getIt.registerFactory(() => ShareToCatalogUseCase(getIt()));
  getIt.registerFactory(() => GetNextPluUseCase(getIt()));
  getIt.registerFactory(() => UploadProductImageUseCase(getIt()));
  getIt.registerFactory(() => DeleteProductImageUseCase(getIt()));

  // --- features/master_catalog ---
  getIt.registerLazySingleton(() => MasterCatalogRemoteDataSource(mainDio));
  getIt.registerLazySingleton<MasterCatalogRepository>(() => MasterCatalogRepositoryImpl(getIt()));
  getIt.registerFactory(() => SearchMasterCatalogUseCase(getIt()));

  // --- features/dashboard ---
  getIt.registerLazySingleton(() => ReportingRemoteDataSource(mainDio));
  getIt.registerLazySingleton<ReportingRepository>(() => ReportingRepositoryImpl(getIt()));
  getIt.registerFactory(() => GetWholesalerDashboardUseCase(getIt()));
  getIt.registerFactory(() => GetRetailerDashboardUseCase(getIt()));
  getIt.registerFactory(() => GetIncomeDebtChartUseCase(getIt()));

  // --- features/catalog (buyer-facing browsing, for the create-order flow) ---
  getIt.registerLazySingleton(() => CatalogRemoteDataSource(mainDio));
  getIt.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListCatalogSellersUseCase(getIt()));
  getIt.registerFactory(() => ListSellerStoresUseCase(getIt()));
  getIt.registerFactory(() => BrowseCatalogUseCase(getIt()));

  // --- features/orders ---
  getIt.registerLazySingleton(() => OrdersRemoteDataSource(mainDio));
  getIt.registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListOrdersUseCase(getIt()));
  getIt.registerFactory(() => GetOrderUseCase(getIt()));
  getIt.registerFactory(() => CreateOrderUseCase(getIt()));
  getIt.registerFactory(() => UpdateOrderStatusUseCase(getIt()));
}

/// The main authenticated [Dio] instance — for feature data sources
/// registered outside this file (e.g. future `products`/`orders` modules).
Dio get mainDio => getIt<Dio>(instanceName: _mainDioInstance);
