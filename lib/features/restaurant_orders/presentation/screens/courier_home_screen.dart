import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/widgets/telegram_notifications_tile.dart';
import 'package:bsmart/features/deliveries/presentation/providers/courier_deliveries_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/screens/courier_deliveries_tab.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_orders_board_screen.dart';
import 'package:bsmart/features/tracking/presentation/widgets/courier_online_card.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_pill.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/shared/widgets/settings_action_button.dart';

/// A courier's own home. For a RESTAURANT-vertical owner's courier, this is
/// the real, working delivery-claiming flow — the same order board every
/// other role sees, already scoped server-side (`TenantFilter
/// .restaurantOrder` + `RestaurantOrderService`'s courier-specific query
/// narrowing) to unclaimed-or-mine `DELIVERY` orders only, so no extra
/// client-side filtering is needed here.
///
/// Every courier (any vertical) also gets the live-location controls: the
/// online/offline [CourierOnlineCard] on top and the AppBar
/// [TrackingStatusPill] (see CLAUDE.md "Courier Delivery & Live Tracking").
///
/// Deliveries (`/deliveries`, see CLAUDE.md "Courier Delivery & Live Tracking")
/// are the courier's main list for every vertical; a restaurant courier also
/// keeps the existing order board as a second tab (restaurant deliveries are
/// accepted there and then show up under "Yetkazishlar").
///
/// Historical note: for every other vertical, no delivery/order-assignment
/// concept existed on the backend at all before Phase 5 — matching the reference web app's own explicit,
/// documented scope decision (`CLAUDE.md` "Courier Feature (Cross-Vertical)":
/// "account management only... courier-home is a static placeholder"), this
/// shows the equivalent placeholder rather than an empty/broken board.
class CourierHomeScreen extends ConsumerWidget {
  const CourierHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
    final isRestaurantCourier =
        session?.ownerRole == UserRole.retailer && session?.businessType == BusinessType.restaurant;

    return Scaffold(
      appBar: AppBar(
        title: Text(UserRole.courier.localizedLabel(context.l10n)),
        actions: [
          const TrackingStatusPill(),
          const CourierAlertsButton(),
          const SettingsActionButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: context.l10n.commonLogout,
            onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          const CourierOnlineCard(),
          Expanded(child: isRestaurantCourier ? const _RestaurantCourierTabs() : const CourierDeliveriesTab()),
        ],
      ),
    );
  }
}

/// Restaurant couriers: Yetkazishlar + the existing order board. Restaurant
/// deliveries are accepted on the board and then appear under Yetkazishlar, so
/// switching back to that tab refreshes it.
class _RestaurantCourierTabs extends ConsumerStatefulWidget {
  const _RestaurantCourierTabs();

  @override
  ConsumerState<_RestaurantCourierTabs> createState() => _RestaurantCourierTabsState();
}

class _RestaurantCourierTabsState extends ConsumerState<_RestaurantCourierTabs> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this)..addListener(_onTab);

  void _onTab() {
    if (!_tabs.indexIsChanging && _tabs.index == 0) ref.read(courierDeliveriesProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: context.l10n.navDeliveries),
            Tab(text: context.l10n.navOrders),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [CourierDeliveriesTab(), RestaurantOrdersBoardScreen(showAppBar: false)],
          ),
        ),
      ],
    );
  }
}
