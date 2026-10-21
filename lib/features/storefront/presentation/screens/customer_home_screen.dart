import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/favorites/presentation/screens/favorites_tab.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';
import 'package:bsmart/features/storefront/presentation/screens/storefront_cart_tab.dart';
import 'package:bsmart/features/storefront/presentation/screens/storefront_catalog_tab.dart';
import 'package:bsmart/features/storefront/presentation/screens/storefront_profile_tab.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_bottom_nav.dart';
import 'package:bsmart/core/l10n/l10n.dart';

/// The guest-eligible storefront shell — Katalog/Savat/Sevimlilar/Profil as
/// an `IndexedStack` inside one route (`RouteNames.customerHome`) rather
/// than a `StatefulShellRoute`, so switching tabs preserves each tab's
/// scroll/filter state for free without extra go_router plumbing (the app
/// has no other bottom-nav shell yet to be consistent with — see
/// `CLAUDE.md`'s Phase 2 notes on this deliberate simplification). The
/// route itself carries no login requirement — see `app_router.dart`'s
/// guest-allowed list; each tab decides its own guest-vs-logged-in content.
///
/// Phase 9: every tab and the tab bar use the brand theme and draw their own
/// headers (no AppBar).
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  static const _catalogTab = 0;
  static const _profileTab = 3;

  int _tabIndex = _catalogTab;

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(storefrontCartProvider).itemCount;
    final l10n = context.l10n;
    final titles = [l10n.navCatalog, l10n.navCart, l10n.navFavorites, l10n.navProfile];
    final brandTheme = BrandTheme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          Theme(
            data: brandTheme,
            child: StorefrontCatalogTab(onOpenProfile: () => setState(() => _tabIndex = _profileTab)),
          ),
          Theme(
            data: brandTheme,
            child: StorefrontCartTab(onStartShopping: () => setState(() => _tabIndex = _catalogTab)),
          ),
          Theme(
            data: brandTheme,
            child: FavoritesTab(onStartShopping: () => setState(() => _tabIndex = _catalogTab)),
          ),
          Theme(data: brandTheme, child: const StorefrontProfileTab()),
        ],
      ),
      bottomNavigationBar: Theme(
        data: brandTheme,
        child: StorefrontBottomNav(
          selectedIndex: _tabIndex,
          onSelected: (index) => setState(() => _tabIndex = index),
          items: [
            StorefrontNavItem(
              icon: Icons.storefront_outlined,
              selectedIcon: Icons.storefront_rounded,
              label: titles[0],
            ),
            StorefrontNavItem(
              icon: Icons.shopping_bag_outlined,
              selectedIcon: Icons.shopping_bag_rounded,
              label: titles[1],
              badge: cartItemCount,
            ),
            StorefrontNavItem(
              icon: Icons.favorite_border_rounded,
              selectedIcon: Icons.favorite_rounded,
              label: titles[2],
            ),
            StorefrontNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: titles[3]),
          ],
        ),
      ),
    );
  }
}
