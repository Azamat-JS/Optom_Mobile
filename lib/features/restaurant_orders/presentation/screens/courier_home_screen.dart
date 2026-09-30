import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_orders_board_screen.dart';
import 'package:bsmart/features/tracking/presentation/widgets/courier_online_card.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_pill.dart';

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
/// For every other vertical, no delivery/order-assignment concept exists yet
/// on the backend at all — matching the reference web app's own explicit,
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
        title: const Text('Kuryer'),
        actions: [
          const TrackingStatusPill(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Chiqish',
            onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          const CourierOnlineCard(),
          Expanded(
            child: isRestaurantCourier
                ? const RestaurantOrdersBoardScreen(showAppBar: false)
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Sizga hali topshiriq biriktirilmagan',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
