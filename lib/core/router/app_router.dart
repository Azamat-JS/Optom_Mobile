import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/router/transitions.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/screens/login_screen.dart';
import 'package:bsmart/features/auth/presentation/screens/splash_screen.dart';
import 'package:bsmart/features/customers/presentation/screens/customers_list_screen.dart';
import 'package:bsmart/features/dashboard/presentation/screens/home_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/order_catalog_browse_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/order_review_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:bsmart/features/orders/presentation/screens/seller_picker_screen.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/presentation/screens/product_detail_screen.dart';
import 'package:bsmart/features/products/presentation/screens/product_form_screen.dart';
import 'package:bsmart/features/products/presentation/screens/products_list_screen.dart';
import 'package:bsmart/features/sales/presentation/screens/pos_screen.dart';
import 'package:bsmart/features/sales/presentation/screens/sales_list_screen.dart';

/// Notifies [GoRouter] to re-run its `redirect` whenever auth state changes,
/// so e.g. a forced logout (refresh-token failure) immediately routes back
/// to `/login` without the user having to trigger navigation themselves.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(sessionNotifierProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
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
    ],
  );
});

/// Single source of truth for "where should the user be right now," so no
/// screen ever calls `context.go(...)` on its own after a login/logout —
/// state changes flow through [sessionNotifierProvider] and this redirect
/// reacts to them. Phase 2+ replaces the flat `/login`/`/home` pair with
/// per-role `StatefulShellRoute`s (see the implementation plan, section 2.6);
/// this stays the one place that decides *whether* the user may be there.
String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(sessionNotifierProvider);
  final isSplash = state.matchedLocation == RouteNames.splash;
  final isLoggingIn = state.matchedLocation == RouteNames.login;

  if (authState.isLoading) {
    return isSplash ? null : RouteNames.splash;
  }

  final loggedIn = authState.valueOrNull?.isAuthenticated ?? false;

  if (!loggedIn) {
    return isLoggingIn ? null : RouteNames.login;
  }

  if (isLoggingIn || isSplash) {
    return RouteNames.home;
  }

  return null;
}
