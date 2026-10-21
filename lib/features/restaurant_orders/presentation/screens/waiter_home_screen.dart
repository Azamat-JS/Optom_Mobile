import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_orders_board_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/waiter_menu_tab.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_bottom_nav.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The narrow `WAITER` shell — order-taking (order board) + a read-only
/// Menu, exactly the plan's "2-3 tabs" scope. Phase 9: a `DashPage` header
/// (settings, logout) and the storefront's yellow-pill tab bar. `IndexedStack`-based, same
/// deliberate choice as `CustomerHomeScreen` (Phase 2) over a go_router
/// `StatefulShellRoute` — no other bottom-nav shell in this app uses one
/// either, so staying consistent matters more than the marginal ergonomics.
class WaiterHomeScreen extends ConsumerStatefulWidget {
  const WaiterHomeScreen({super.key});

  @override
  ConsumerState<WaiterHomeScreen> createState() => _WaiterHomeScreenState();
}

class _WaiterHomeScreenState extends ConsumerState<WaiterHomeScreen> {
  int _index = 0;

  static const _screens = [RestaurantOrdersBoardScreen(showAppBar: false), WaiterMenuTab()];
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [l10n.navOrders, l10n.navMenu];
    return DashPage(
      title: titles[_index],
      showBack: false,
      actions: [
        DashRoundButton(
          icon: Icons.settings_outlined,
          tooltip: l10n.commonSettings,
          onTap: () => context.push(RouteNames.settings),
        ),
        DashRoundButton(
          icon: Icons.logout_rounded,
          tooltip: l10n.commonLogout,
          onTap: () => ref.read(sessionNotifierProvider.notifier).logout(),
        ),
      ],
      bottomBar: StorefrontBottomNav(
        selectedIndex: _index,
        onSelected: (index) => setState(() => _index = index),
        items: [
          StorefrontNavItem(
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            label: titles[0],
          ),
          StorefrontNavItem(
            icon: Icons.restaurant_menu_outlined,
            selectedIcon: Icons.restaurant_menu_rounded,
            label: titles[1],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
    );
  }
}
