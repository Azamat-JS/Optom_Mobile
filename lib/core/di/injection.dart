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
import 'package:bsmart/features/auth/domain/usecases/register_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/verify_password_usecase.dart';
import 'package:bsmart/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:bsmart/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:bsmart/features/categories/domain/repositories/categories_repository.dart';
import 'package:bsmart/features/categories/domain/usecases/create_category_usecase.dart';
import 'package:bsmart/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:bsmart/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:bsmart/features/categories/domain/usecases/list_categories_paginated_usecase.dart';
import 'package:bsmart/features/categories/domain/usecases/update_category_usecase.dart';
import 'package:bsmart/features/categories/domain/usecases/upload_category_image_usecase.dart';
import 'package:bsmart/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:bsmart/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:bsmart/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:bsmart/features/catalog/domain/usecases/browse_catalog_usecase.dart';
import 'package:bsmart/features/catalog/domain/usecases/list_catalog_sellers_usecase.dart';
import 'package:bsmart/features/catalog/domain/usecases/list_seller_stores_usecase.dart';
import 'package:bsmart/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:bsmart/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:bsmart/features/customers/domain/repositories/customers_repository.dart';
import 'package:bsmart/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/deactivate_customer_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/delete_customer_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/get_customer_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/list_customers_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/update_customer_usecase.dart';
import 'package:bsmart/features/dashboard/data/datasources/reporting_remote_data_source.dart';
import 'package:bsmart/features/debts/data/datasources/debts_remote_data_source.dart';
import 'package:bsmart/features/debts/data/datasources/payments_remote_data_source.dart';
import 'package:bsmart/features/debts/data/datasources/sale_debts_remote_data_source.dart';
import 'package:bsmart/features/debts/data/repositories/debts_repository_impl.dart';
import 'package:bsmart/features/debts/domain/repositories/debts_repository.dart';
import 'package:bsmart/features/debts/domain/usecases/close_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/create_payment_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/get_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/get_sale_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/list_debts_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/list_sale_debts_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/pay_down_usecase.dart';
import 'package:bsmart/features/dashboard/data/repositories/reporting_repository_impl.dart';
import 'package:bsmart/features/dashboard/domain/repositories/reporting_repository.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_income_debt_chart_usecase.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_retailer_dashboard_usecase.dart';
import 'package:bsmart/features/dashboard/domain/usecases/get_wholesaler_dashboard_usecase.dart';
import 'package:bsmart/features/master_catalog/data/datasources/master_catalog_remote_data_source.dart';
import 'package:bsmart/features/master_catalog/data/repositories/master_catalog_repository_impl.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/approve_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/create_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/delete_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/get_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/reject_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/remove_master_product_image_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/search_master_catalog_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/update_master_product_usecase.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/upload_master_product_image_usecase.dart';
import 'package:bsmart/features/platform_dashboard/data/datasources/platform_dashboard_remote_data_source.dart';
import 'package:bsmart/features/platform_dashboard/data/repositories/platform_dashboard_repository_impl.dart';
import 'package:bsmart/features/platform_dashboard/domain/repositories/platform_dashboard_repository.dart';
import 'package:bsmart/features/platform_dashboard/domain/usecases/get_platform_dashboard_usecase.dart';
import 'package:bsmart/features/platform_dashboard/domain/usecases/get_platform_income_debt_chart_usecase.dart';
import 'package:bsmart/features/platform_users/data/datasources/platform_users_remote_data_source.dart';
import 'package:bsmart/features/platform_users/data/repositories/platform_users_repository_impl.dart';
import 'package:bsmart/features/platform_users/domain/repositories/platform_users_repository.dart';
import 'package:bsmart/features/platform_users/domain/usecases/create_platform_user_usecase.dart';
import 'package:bsmart/features/platform_users/domain/usecases/delete_platform_user_usecase.dart';
import 'package:bsmart/features/platform_users/domain/usecases/list_platform_users_usecase.dart';
import 'package:bsmart/features/platform_users/domain/usecases/set_platform_user_active_usecase.dart';
import 'package:bsmart/features/platform_users/domain/usecases/update_platform_user_usecase.dart';
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
import 'package:bsmart/features/products/domain/usecases/get_best_selling_products_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/delete_product_image_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/get_next_plu_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/get_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/receive_stock_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/share_to_catalog_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/update_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/upload_product_image_usecase.dart';
import 'package:bsmart/features/expenditures/data/datasources/expenditures_remote_data_source.dart';
import 'package:bsmart/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:bsmart/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:bsmart/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:bsmart/features/favorites/domain/usecases/list_favorite_ids_usecase.dart';
import 'package:bsmart/features/favorites/domain/usecases/list_favorites_usecase.dart';
import 'package:bsmart/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:bsmart/features/expenditures/data/repositories/expenditures_repository_impl.dart';
import 'package:bsmart/features/expenditures/domain/repositories/expenditures_repository.dart';
import 'package:bsmart/features/expenditures/domain/usecases/create_expenditure_usecase.dart';
import 'package:bsmart/features/expenditures/domain/usecases/delete_expenditure_usecase.dart';
import 'package:bsmart/features/expenditures/domain/usecases/list_expenditures_usecase.dart';
import 'package:bsmart/features/expenditures/domain/usecases/update_expenditure_usecase.dart';
import 'package:bsmart/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:bsmart/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:bsmart/features/reports/domain/repositories/reports_repository.dart';
import 'package:bsmart/features/reports/domain/usecases/end_work_day_usecase.dart';
import 'package:bsmart/features/reports/domain/usecases/export_debts_xlsx_usecase.dart';
import 'package:bsmart/features/reports/domain/usecases/get_current_work_day_usecase.dart';
import 'package:bsmart/features/reports/domain/usecases/get_period_stats_usecase.dart';
import 'package:bsmart/features/reports/domain/usecases/get_sales_chart_usecase.dart';
import 'package:bsmart/features/reports/domain/usecases/start_work_day_usecase.dart';
import 'package:bsmart/features/storefront/data/datasources/storefront_remote_data_source.dart';
import 'package:bsmart/features/storefront/data/repositories/storefront_repository_impl.dart';
import 'package:bsmart/features/storefront/domain/repositories/storefront_repository.dart';
import 'package:bsmart/features/storefront/domain/usecases/browse_storefront_usecase.dart';
import 'package:bsmart/features/storefront/domain/usecases/get_storefront_product_usecase.dart';
import 'package:bsmart/features/storefront/domain/usecases/list_storefront_categories_usecase.dart';
import 'package:bsmart/features/staff_admins/data/datasources/admins_remote_data_source.dart';
import 'package:bsmart/features/staff_admins/data/repositories/admins_repository_impl.dart';
import 'package:bsmart/features/staff_admins/domain/repositories/admins_repository.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/create_admin_usecase.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/delete_admin_usecase.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/list_admins_usecase.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/set_admin_active_usecase.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/update_admin_usecase.dart';
import 'package:bsmart/features/stores/data/datasources/stores_remote_data_source.dart';
import 'package:bsmart/features/stores/data/repositories/stores_repository_impl.dart';
import 'package:bsmart/features/stores/domain/repositories/stores_repository.dart';
import 'package:bsmart/features/stores/domain/usecases/create_store_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/delete_store_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/list_stores_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/set_store_active_usecase.dart';
import 'package:bsmart/features/stores/domain/usecases/update_store_usecase.dart';
import 'package:bsmart/features/sales/data/datasources/sales_remote_data_source.dart';
import 'package:bsmart/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:bsmart/features/sales/domain/repositories/sales_repository.dart';
import 'package:bsmart/features/sales/domain/usecases/create_sale_return_usecase.dart';
import 'package:bsmart/features/sales/domain/usecases/create_sale_usecase.dart';
import 'package:bsmart/features/sales/domain/usecases/get_sale_usecase.dart';
import 'package:bsmart/features/sales/domain/usecases/list_sales_usecase.dart';

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
  getIt.registerFactory(() => RegisterUseCase(getIt()));
  getIt.registerFactory(() => LogoutUseCase(getIt()));
  getIt.registerFactory(() => GetCurrentUserUseCase(getIt()));
  getIt.registerFactory(() => UpdateProfileUseCase(getIt()));
  getIt.registerFactory(() => VerifyPasswordUseCase(getIt()));

  // --- features/categories ---
  getIt.registerLazySingleton(() => CategoriesRemoteDataSource(mainDio));
  getIt.registerLazySingleton<CategoriesRepository>(() => CategoriesRepositoryImpl(getIt()));
  getIt.registerFactory(() => GetCategoriesUseCase(getIt()));
  getIt.registerFactory(() => ListCategoriesPaginatedUseCase(getIt()));
  getIt.registerFactory(() => CreateCategoryUseCase(getIt()));
  getIt.registerFactory(() => UpdateCategoryUseCase(getIt()));
  getIt.registerFactory(() => UploadCategoryImageUseCase(getIt()));
  getIt.registerFactory(() => DeleteCategoryUseCase(getIt()));

  // --- features/products ---
  getIt.registerLazySingleton(() => ProductsRemoteDataSource(mainDio));
  getIt.registerLazySingleton<ProductsRepository>(() => ProductsRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListProductsUseCase(getIt()));
  getIt.registerFactory(() => GetProductUseCase(getIt()));
  getIt.registerFactory(() => CreateProductUseCase(getIt()));
  getIt.registerFactory(() => GetBestSellingProductsUseCase(getIt()));
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
  getIt.registerFactory(() => GetMasterProductUseCase(getIt()));
  getIt.registerFactory(() => CreateMasterProductUseCase(getIt()));
  getIt.registerFactory(() => UpdateMasterProductUseCase(getIt()));
  getIt.registerFactory(() => ApproveMasterProductUseCase(getIt()));
  getIt.registerFactory(() => RejectMasterProductUseCase(getIt()));
  getIt.registerFactory(() => DeleteMasterProductUseCase(getIt()));
  getIt.registerFactory(() => UploadMasterProductImageUseCase(getIt()));
  getIt.registerFactory(() => RemoveMasterProductImageUseCase(getIt()));

  // --- features/platform_users (Phase 3, SUPER_ADMIN) ---
  getIt.registerLazySingleton(() => PlatformUsersRemoteDataSource(mainDio));
  getIt.registerLazySingleton<PlatformUsersRepository>(() => PlatformUsersRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListPlatformUsersUseCase(getIt()));
  getIt.registerFactory(() => CreatePlatformUserUseCase(getIt()));
  getIt.registerFactory(() => UpdatePlatformUserUseCase(getIt()));
  getIt.registerFactory(() => SetPlatformUserActiveUseCase(getIt()));
  getIt.registerFactory(() => DeletePlatformUserUseCase(getIt()));

  // --- features/platform_dashboard (Phase 3, SUPER_ADMIN) ---
  getIt.registerLazySingleton(() => PlatformDashboardRemoteDataSource(mainDio));
  getIt.registerLazySingleton<PlatformDashboardRepository>(() => PlatformDashboardRepositoryImpl(getIt()));
  getIt.registerFactory(() => GetPlatformDashboardUseCase(getIt()));
  getIt.registerFactory(() => GetPlatformIncomeDebtChartUseCase(getIt()));

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

  // --- features/customers ---
  getIt.registerLazySingleton(() => CustomersRemoteDataSource(mainDio));
  getIt.registerLazySingleton<CustomersRepository>(() => CustomersRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListCustomersUseCase(getIt()));
  getIt.registerFactory(() => GetCustomerUseCase(getIt()));
  getIt.registerFactory(() => CreateCustomerUseCase(getIt()));
  getIt.registerFactory(() => UpdateCustomerUseCase(getIt()));
  getIt.registerFactory(() => DeactivateCustomerUseCase(getIt()));
  getIt.registerFactory(() => DeleteCustomerUseCase(getIt()));

  // --- features/sales (POS Sell tab reuses this same B2C endpoint) ---
  getIt.registerLazySingleton(() => SalesRemoteDataSource(mainDio));
  getIt.registerLazySingleton<SalesRepository>(() => SalesRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListSalesUseCase(getIt()));
  getIt.registerFactory(() => GetSaleUseCase(getIt()));
  getIt.registerFactory(() => CreateSaleUseCase(getIt()));
  getIt.registerFactory(() => CreateSaleReturnUseCase(getIt()));

  // --- features/debts (Debt/SaleDebt + Payment/pay-down) ---
  getIt.registerLazySingleton(() => DebtsRemoteDataSource(mainDio));
  getIt.registerLazySingleton(() => SaleDebtsRemoteDataSource(mainDio));
  getIt.registerLazySingleton(() => PaymentsRemoteDataSource(mainDio));
  getIt.registerLazySingleton<DebtsRepository>(() => DebtsRepositoryImpl(getIt(), getIt(), getIt()));
  getIt.registerFactory(() => ListDebtsUseCase(getIt()));
  getIt.registerFactory(() => ListSaleDebtsUseCase(getIt()));
  getIt.registerFactory(() => GetDebtUseCase(getIt()));
  getIt.registerFactory(() => GetSaleDebtUseCase(getIt()));
  getIt.registerFactory(() => CloseDebtUseCase(getIt()));
  getIt.registerFactory(() => CreatePaymentUseCase(getIt()));
  getIt.registerFactory(() => PayDownUseCase(getIt()));

  // --- features/stores ---
  getIt.registerLazySingleton(() => StoresRemoteDataSource(mainDio));
  getIt.registerLazySingleton<StoresRepository>(() => StoresRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListStoresUseCase(getIt()));
  getIt.registerFactory(() => CreateStoreUseCase(getIt()));
  getIt.registerFactory(() => UpdateStoreUseCase(getIt()));
  getIt.registerFactory(() => SetStoreActiveUseCase(getIt()));
  getIt.registerFactory(() => DeleteStoreUseCase(getIt()));

  // --- features/staff_admins ---
  getIt.registerLazySingleton(() => AdminsRemoteDataSource(mainDio));
  getIt.registerLazySingleton<AdminsRepository>(() => AdminsRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListAdminsUseCase(getIt()));
  getIt.registerFactory(() => CreateAdminUseCase(getIt()));
  getIt.registerFactory(() => UpdateAdminUseCase(getIt()));
  getIt.registerFactory(() => SetAdminActiveUseCase(getIt()));
  getIt.registerFactory(() => DeleteAdminUseCase(getIt()));

  // --- features/expenditures ---
  getIt.registerLazySingleton(() => ExpendituresRemoteDataSource(mainDio));
  getIt.registerLazySingleton<ExpendituresRepository>(() => ExpendituresRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListExpendituresUseCase(getIt()));
  getIt.registerFactory(() => CreateExpenditureUseCase(getIt()));
  getIt.registerFactory(() => UpdateExpenditureUseCase(getIt()));
  getIt.registerFactory(() => DeleteExpenditureUseCase(getIt()));

  // --- features/reports (period-stats/sales-chart + work-day) ---
  getIt.registerLazySingleton(() => ReportsRemoteDataSource(mainDio));
  getIt.registerLazySingleton<ReportsRepository>(() => ReportsRepositoryImpl(getIt()));
  getIt.registerFactory(() => GetPeriodStatsUseCase(getIt()));
  getIt.registerFactory(() => GetSalesChartUseCase(getIt()));
  getIt.registerFactory(() => GetCurrentWorkDayUseCase(getIt()));
  getIt.registerFactory(() => StartWorkDayUseCase(getIt()));
  getIt.registerFactory(() => EndWorkDayUseCase(getIt()));
  getIt.registerFactory(() => ExportDebtsXlsxUseCase(getIt()));

  // --- features/storefront (Phase 2: guest-eligible public catalog + cart) ---
  getIt.registerLazySingleton(() => StorefrontRemoteDataSource(publicDio));
  getIt.registerLazySingleton<StorefrontRepository>(() => StorefrontRepositoryImpl(getIt()));
  getIt.registerFactory(() => ListStorefrontCategoriesUseCase(getIt()));
  getIt.registerFactory(() => BrowseStorefrontUseCase(getIt()));
  getIt.registerFactory(() => GetStorefrontProductUseCase(getIt()));

  // --- features/favorites (Phase 2) ---
  getIt.registerLazySingleton(() => FavoritesRemoteDataSource(mainDio));
  getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(getIt()));
  getIt.registerFactory(() => ToggleFavoriteUseCase(getIt()));
  getIt.registerFactory(() => ListFavoritesUseCase(getIt()));
  getIt.registerFactory(() => ListFavoriteIdsUseCase(getIt()));
}

/// The main authenticated [Dio] instance — for feature data sources
/// registered outside this file (e.g. future `products`/`orders` modules).
Dio get mainDio => getIt<Dio>(instanceName: _mainDioInstance);

/// The interceptor-free [Dio] instance — for the guest-eligible storefront
/// (Phase 2), which must never send an `Authorization` header.
Dio get publicDio => getIt<Dio>(instanceName: _bareDioInstance);
