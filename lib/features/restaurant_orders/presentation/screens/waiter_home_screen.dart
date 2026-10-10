import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_orders_board_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/waiter_menu_tab.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/shared/widgets/settings_action_button.dart';

/// The narrow `WAITER` shell — order-taking (order board) + a read-only
/// Menu, exactly the plan's "2-3 tabs" scope. `IndexedStack`-based, same
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
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          const SettingsActionButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.commonLogout,
            onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: titles[0]),
          NavigationDestination(icon: const Icon(Icons.restaurant_menu_outlined), label: titles[1]),
        ],
      ),
    );
  }
}
