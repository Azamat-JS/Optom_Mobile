import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/features/favorites/presentation/screens/favorites_tab.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';
import 'package:bsmart/features/storefront/presentation/screens/storefront_cart_tab.dart';
import 'package:bsmart/features/storefront/presentation/screens/storefront_catalog_tab.dart';
import 'package:bsmart/features/storefront/presentation/screens/storefront_profile_tab.dart';
import 'package:bsmart/core/l10n/l10n.dart';

/// The guest-eligible storefront shell — Katalog/Savat/Sevimlilar/Profil as
/// an `IndexedStack` inside one route (`RouteNames.customerHome`) rather
/// than a `StatefulShellRoute`, so switching tabs preserves each tab's
/// scroll/filter state for free without extra go_router plumbing (the app
/// has no other bottom-nav shell yet to be consistent with — see
/// `CLAUDE.md`'s Phase 2 notes on this deliberate simplification). The
/// route itself carries no login requirement — see `app_router.dart`'s
/// guest-allowed list; each tab decides its own guest-vs-logged-in content.
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(storefrontCartProvider).itemCount;
    final l10n = context.l10n;
    final titles = [l10n.navCatalog, l10n.navCart, l10n.navFavorites, l10n.navProfile];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_tabIndex])),
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          StorefrontCatalogTab(),
          StorefrontCartTab(),
          FavoritesTab(),
          StorefrontProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.storefront_outlined), label: titles[0]),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartItemCount'),
              isLabelVisible: cartItemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: titles[1],
          ),
          NavigationDestination(icon: const Icon(Icons.favorite_border), label: titles[2]),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: titles[3]),
        ],
      ),
    );
  }
}
