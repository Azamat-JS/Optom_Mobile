import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/widgets/telegram_notifications_tile.dart';
import 'package:bsmart/features/deliveries/presentation/providers/courier_deliveries_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/courier_deliveries_tab.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_orders_board_screen.dart';
import 'package:bsmart/features/tracking/presentation/widgets/courier_online_card.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// A courier's own home. For a RESTAURANT-vertical owner's courier, this is
/// the real, working delivery-claiming flow — the same order board every
/// other role sees, already scoped server-side (`TenantFilter
/// .restaurantOrder` + `RestaurantOrderService`'s courier-specific query
/// narrowing) to unclaimed-or-mine `DELIVERY` orders only, so no extra
/// client-side filtering is needed here.
///
/// Every courier (any vertical) also gets the live-location controls: the
/// online/offline [CourierOnlineCard] on top, which carries the live
/// `TrackingStatusPill` while online (see CLAUDE.md "Courier Delivery & Live
/// Tracking").
///
/// Deliveries (`/deliveries`, see CLAUDE.md "Courier Delivery & Live Tracking")
/// are the courier's main list for every vertical; a restaurant courier also
/// keeps the existing order board behind a Yetkazishlar / Buyurtmalar pill
/// toggle (restaurant deliveries are accepted there and then show up under
/// "Yetkazishlar").
///
/// Historical note: for every other vertical, no delivery/order-assignment
/// concept existed on the backend at all before Phase 5 — matching the reference web app's own explicit,
/// documented scope decision (`CLAUDE.md` "Courier Feature (Cross-Vertical)":
/// "account management only... courier-home is a static placeholder"), this
/// shows the equivalent placeholder rather than an empty/broken board.
class CourierHomeScreen extends ConsumerStatefulWidget {
  const CourierHomeScreen({super.key});

  @override
  ConsumerState<CourierHomeScreen> createState() => _CourierHomeScreenState();
}

class _CourierHomeScreenState extends ConsumerState<CourierHomeScreen> {
  /// Restaurant couriers only: 0 = Yetkazishlar, 1 = the order board.
  int _tab = 0;

  void _selectTab(int tab) {
    // Restaurant deliveries are accepted on the board and then appear under
    // Yetkazishlar, so switching back refreshes it.
    if (tab == 0 && _tab != 0) ref.read(courierDeliveriesProvider.notifier).refresh();
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
    final isRestaurantCourier =
        session?.ownerRole == UserRole.retailer && session?.businessType == BusinessType.restaurant;

    return DashPage(
      title: UserRole.courier.localizedLabel(l10n),
      showBack: false,
      actions: [
        const CourierAlertsButton(),
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
      header: Column(
        children: [
          const CourierOnlineCard(),
          if (isRestaurantCourier) ...[
            const SizedBox(height: 12),
            PillToggle<int>(
              values: const [0, 1],
              selected: _tab,
              label: (i) => i == 0 ? l10n.navDeliveries : l10n.navOrders,
              onChanged: _selectTab,
              expand: true,
            ),
          ],
        ],
      ),
      body: isRestaurantCourier
          ? IndexedStack(
              index: _tab,
              children: const [CourierDeliveriesTab(), RestaurantOrdersBoardScreen(showAppBar: false)],
            )
          : const CourierDeliveriesTab(),
    );
  }
}
