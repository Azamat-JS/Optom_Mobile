import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/router/transitions.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/screens/login_screen.dart';
import 'package:bsmart/features/auth/presentation/screens/register_screen.dart';
import 'package:bsmart/features/auth/presentation/screens/splash_screen.dart';
import 'package:bsmart/features/auth/presentation/screens/telegram_verify_screen.dart';
import 'package:bsmart/features/deliveries/presentation/screens/customer_deliveries_screen.dart';
import 'package:bsmart/features/customers/presentation/screens/customers_list_screen.dart';
import 'package:bsmart/features/dashboard/presentation/screens/home_screen.dart';
import 'package:bsmart/features/debts/presentation/screens/debts_list_screen.dart';
import 'package:bsmart/features/expenditures/presentation/screens/expenditures_list_screen.dart';
import 'package:bsmart/features/reports/presentation/screens/reports_screen.dart';
import 'package:bsmart/features/staff_admins/presentation/screens/admins_list_screen.dart';
import 'package:bsmart/features/storefront/presentation/screens/customer_debts_screen.dart';
import 'package:bsmart/features/storefront/presentation/screens/customer_home_screen.dart';
import 'package:bsmart/features/storefront/presentation/screens/storefront_cart_review_screen.dart';
import 'package:bsmart/features/storefront/presentation/screens/storefront_product_detail_screen.dart';
import 'package:bsmart/features/stores/presentation/screens/stores_list_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/order_catalog_browse_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/order_review_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/seller_picker_screen.dart';
import 'package:bsmart/features/categories/presentation/screens/categories_admin_list_screen.dart';
import 'package:bsmart/features/master_catalog/presentation/screens/master_catalog_admin_list_screen.dart';
import 'package:bsmart/features/platform_dashboard/presentation/screens/super_admin_home_screen.dart';
import 'package:bsmart/features/platform_users/presentation/screens/platform_users_list_screen.dart';
import 'package:bsmart/features/courier/presentation/screens/couriers_list_screen.dart';
import 'package:bsmart/features/fleet/presentation/screens/fleet_map_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/courier_home_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_orders_board_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/waiter_home_screen.dart';
import 'package:bsmart/features/restaurant_staff/presentation/screens/waiters_list_screen.dart';
import 'package:bsmart/features/restaurant_tables/presentation/screens/restaurant_tables_list_screen.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/presentation/screens/product_detail_screen.dart';
import 'package:bsmart/features/products/presentation/screens/product_form_screen.dart';
import 'package:bsmart/features/products/presentation/screens/products_list_screen.dart';
import 'package:bsmart/features/sales/presentation/screens/pos_screen.dart';
import 'package:bsmart/features/sales/presentation/screens/sales_list_screen.dart';
import 'package:bsmart/features/settings/presentation/screens/settings_screen.dart';

/// Notifies [GoRouter] to re-run its `redirect` whenever auth state changes,
/// so e.g. a forced logout (refresh-token failure) immediately routes back
/// to `/login` without the user having to trigger navigation themselves.
///
/// Only routing-relevant changes (loading, who is signed in, their role)
/// trigger it. A same-user session update — e.g. Phase 6's "Raqamni
/// tasdiqlash", which swaps in fresh tokens for the same account — must not:
/// a go_router refresh re-applies the last *pushed* location, which re-opened
/// the just-closed verify screen (and started a second verification).
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(
      sessionNotifierProvider.select(
        (s) => (s.isLoading, s.valueOrNull?.session?.userId, s.valueOrNull?.session?.role),
      ),
      (_, _) => notifyListeners(),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  final router = GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const SplashScreen()),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const RegisterScreen()),
      ),
      GoRoute(
        path: RouteNames.telegramVerify,
        pageBuilder: (context, state) => fadeThroughPage(
          state: state,
          child: TelegramVerifyScreen(phone: state.uri.queryParameters['phone'] ?? ''),
        ),
      ),
      GoRoute(
        path: RouteNames.customerHome,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const CustomerHomeScreen()),
      ),
      GoRoute(
        path: RouteNames.customerProductDetailPattern,
        pageBuilder: (context, state) => fadeThroughPage(
          state: state,
          child: StorefrontProductDetailScreen(productId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: RouteNames.customerCartReview,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const StorefrontCartReviewScreen()),
      ),
      GoRoute(
        path: RouteNames.customerDeliveries,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const CustomerDeliveriesScreen()),
      ),
      GoRoute(
        path: RouteNames.customerVerifyPhone,
        pageBuilder: (context, state) {
          final phone = ref.read(sessionNotifierProvider).valueOrNull?.user?.phone ?? '';
          return fadeThroughPage(
            state: state,
            child: TelegramVerifyScreen(phone: _plus998(phone), verifyCurrentAccount: true),
          );
        },
      ),
      GoRoute(
        path: RouteNames.customerDebts,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const CustomerDebtsScreen()),
      ),
      GoRoute(
        path: RouteNames.settings,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const SettingsScreen()),
      ),
      GoRoute(
        path: RouteNames.home,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const HomeScreen()),
      ),
      GoRoute(
        path: RouteNames.products,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const ProductsListScreen()),
      ),
      GoRoute(
        path: RouteNames.productNew,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const ProductFormScreen()),
      ),
      GoRoute(
        path: RouteNames.productDetailPattern,
        pageBuilder: (context, state) => fadeThroughPage(
          state: state,
          child: ProductDetailScreen(productId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: RouteNames.productEditPattern,
        pageBuilder: (context, state) => fadeThroughPage(
          state: state,
          child: ProductFormScreen(editingProduct: state.extra as Product?),
        ),
      ),
      GoRoute(
        path: RouteNames.orders,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const OrdersListScreen()),
      ),
      GoRoute(
        path: RouteNames.orderNewSellerPicker,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const SellerPickerScreen()),
      ),
      GoRoute(
        path: RouteNames.orderCatalogBrowse,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const OrderCatalogBrowseScreen()),
      ),
      GoRoute(
        path: RouteNames.orderReview,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const OrderReviewScreen()),
      ),
      GoRoute(
        path: RouteNames.orderDetailPattern,
        pageBuilder: (context, state) => fadeThroughPage(
          state: state,
          child: OrderDetailScreen(orderId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: RouteNames.customers,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const CustomersListScreen()),
      ),
      GoRoute(
        path: RouteNames.pos,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const PosScreen()),
      ),
      GoRoute(
        path: RouteNames.sales,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const SalesListScreen()),
      ),
      GoRoute(
        path: RouteNames.debts,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const DebtsListScreen()),
      ),
      GoRoute(
        path: RouteNames.stores,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const StoresListScreen()),
      ),
      GoRoute(
        path: RouteNames.admins,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const AdminsListScreen()),
      ),
      GoRoute(
        path: RouteNames.expenditures,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const ExpendituresListScreen()),
      ),
      GoRoute(
        path: RouteNames.reports,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const ReportsScreen()),
      ),
      GoRoute(
        path: RouteNames.superAdminHome,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const SuperAdminHomeScreen()),
      ),
      GoRoute(
        path: RouteNames.superAdminUsers,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const PlatformUsersListScreen()),
      ),
      GoRoute(
        path: RouteNames.superAdminCategories,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const CategoriesAdminListScreen()),
      ),
      GoRoute(
        path: RouteNames.superAdminCatalog,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const MasterCatalogAdminListScreen()),
      ),
      GoRoute(
        path: RouteNames.waiterHome,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const WaiterHomeScreen()),
      ),
      GoRoute(
        path: RouteNames.courierHome,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const CourierHomeScreen()),
      ),
      GoRoute(
        path: RouteNames.restaurantTables,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const RestaurantTablesListScreen()),
      ),
      GoRoute(
        path: RouteNames.restaurantOrders,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const RestaurantOrdersBoardScreen()),
      ),
      GoRoute(
        path: RouteNames.waiters,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const WaitersListScreen()),
      ),
      GoRoute(
        path: RouteNames.couriers,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const CouriersListScreen()),
      ),
      GoRoute(
        path: RouteNames.fleetMap,
        pageBuilder: (context, state) => fadeThroughPage(state: state, child: const FleetMapScreen()),
      ),
    ],
  );

  // Logging in from a *pushed* auth screen (storefront Profil → Kirish →
  // Telegram wait screen) can't be resolved by [_redirect] alone: on refresh
  // go_router re-pushes the redirect target onto the old stack instead of
  // replacing it, leaving the user on the auth screen. So on a logged-out →
  // logged-in transition, reset the stack via splash; [_redirect] then sends
  // the user to their role's home. Screens still never navigate themselves.
  var wasLoggedIn = false;
  ref.listen(sessionNotifierProvider, (previous, next) {
    if (!next.hasValue) return;
    final isLoggedIn = next.value!.isAuthenticated;
    if (isLoggedIn && !wasLoggedIn) router.go(RouteNames.splash);
    wasLoggedIn = isLoggedIn;
  });

  return router;
});

/// Guest-eligible routes — reachable with no session at all. Everything
/// else redirects to `/login` when logged out. Only the storefront shell
/// itself and its product-detail pushes are guest-eligible; cart checkout,
/// favorites, and "my orders/debts" are reached *through* that shell but
/// still require login — enforced by simply not listing their routes here,
/// not by a per-screen check (`RouteNames.customerCartReview`/`.orders`/
/// `.customerDebts` are absent on purpose). Splash is deliberately not in
/// this set — see [_redirect]'s doc comment for why it needs its own branch.
bool _isGuestAllowed(String location) {
  const allowed = {
    RouteNames.login,
    RouteNames.register,
    RouteNames.telegramVerify,
    RouteNames.customerHome,
    RouteNames.settings,
  };
  if (allowed.contains(location)) return true;
  return location.startsWith('/customer/products/');
}

/// Single source of truth for "where should the user be right now," so no
/// screen ever calls `context.go(...)` on its own after a login/logout —
/// state changes flow through [sessionNotifierProvider] and this redirect
/// reacts to them.
///
/// Phase 1 was a blanket "no session → `/login`" gate; Phase 2's guest
/// storefront needs an allowlist instead (see [_isGuestAllowed]) — everyone
/// else still funnels through the same login-required default. A logged-in
/// `CUSTOMER` lands on the storefront shell instead of the operator
/// `HomeScreen`; a logged-in `SUPER_ADMIN` (Phase 3) lands on
/// `/admin` instead of either. Every other role is unchanged from Phase 1.
///
/// Splash always resolves *away* once loading finishes, for both outcomes —
/// it is deliberately never itself a "stay here" guest-allowed destination
/// (unlike `/customer`), otherwise a guest would sit on the splash spinner
/// forever, since `SplashScreen` never navigates on its own (see its doc
/// comment). A logged-out cold start lands on the storefront (browse first,
/// log in only when needed), not on `/login` — that's still one tap away
/// from the Profil tab or the storefront's own login/register prompts.
String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(sessionNotifierProvider);
  final location = state.matchedLocation;
  final isSplash = location == RouteNames.splash;
  final isAuthScreen = location == RouteNames.login ||
      location == RouteNames.register ||
      location == RouteNames.telegramVerify;

  if (authState.isLoading) {
    return isSplash ? null : RouteNames.splash;
  }

  final session = authState.valueOrNull;
  final loggedIn = session?.isAuthenticated ?? false;
  final role = session?.session?.role;

  if (!loggedIn) {
    if (isSplash) return RouteNames.customerHome;
    return _isGuestAllowed(location) ? null : RouteNames.login;
  }

  if (isAuthScreen || isSplash) return _homeFor(role);

  return null;
}

/// Account phones exist in legacy formats ("998901234567", "901234567"); the
/// verify endpoint wants "+998XXXXXXXXX".
String _plus998(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 9 ? '+998${digits.substring(digits.length - 9)}' : phone;
}

String _homeFor(UserRole? role) {
  if (role == UserRole.superAdmin) return RouteNames.superAdminHome;
  if (role == UserRole.waiter) return RouteNames.waiterHome;
  if (role == UserRole.courier) return RouteNames.courierHome;
  return role == UserRole.customer ? RouteNames.customerHome : RouteNames.home;
}
