import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/presentation/providers/open_restaurant_orders_notifier.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_order_create_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_order_detail_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/widgets/restaurant_order_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The restaurant-orders board — every open (non-terminal) dine-in/delivery
/// order. Independent from the B2B/B2C `Order`/`Sale` pipeline elsewhere in
/// this app (see `RestaurantOrder`'s own doc comment). Reused as-is by
/// `WaiterHomeScreen`'s "Buyurtmalar" tab and `CourierHomeScreen` (both just
/// embed this screen — the backend already scopes a courier's own query to
/// unclaimed-or-mine delivery orders, so no extra client-side filtering is
/// needed here for that role).
class RestaurantOrdersBoardScreen extends ConsumerWidget {
  const RestaurantOrdersBoardScreen({super.key, this.showAppBar = true});

  /// False when embedded inside a shell that already has its own header
  /// (`WaiterHomeScreen`'s tab, `CourierHomeScreen`'s tab): only the list
  /// and the add button, on a transparent background.
  final bool showAppBar;

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const RestaurantOrderCreateScreen()));
    if (created == true) ref.read(openRestaurantOrdersProvider.notifier).refresh();
  }

  void _openDetail(BuildContext context, WidgetRef ref, RestaurantOrder order) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RestaurantOrderDetailScreen(orderId: order.id)))
        .then((_) => ref.read(openRestaurantOrdersProvider.notifier).refresh());
  }

  static final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final ordersAsync = ref.watch(openRestaurantOrdersProvider);
    final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
    final role = session?.role;
    final canCreate = role == UserRole.retailer || role == UserRole.retailerAdmin || role == UserRole.waiter;

    final body = ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => DashEmptyState(
        icon: Icons.cloud_off_rounded,
        text: l10n.commonErrorWith('$error'),
        action: TextButton(
          onPressed: () => ref.invalidate(openRestaurantOrdersProvider),
          child: Text(l10n.commonRetry),
        ),
      ),
      data: (orders) => RefreshIndicator(
        color: AppColors.onBrand,
        backgroundColor: AppColors.brandYellow,
        onRefresh: () => ref.read(openRestaurantOrdersProvider.notifier).refresh(),
        child: orders.isEmpty
            ? const DashEmptyState(icon: Icons.dining_rounded, text: "Ochiq buyurtmalar yo'q")
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final dineIn = order.type == RestaurantOrderType.dineIn;
                  final tint = RestaurantOrderStatusBadge.colorOf(context, order.status);
                  return DashListCard(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: tint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(dineIn ? Icons.table_restaurant_rounded : Icons.moped_rounded, color: tint),
                    ),
                    title: dineIn
                        ? 'Stol: ${order.tableNumber ?? order.table?.name ?? '—'}'
                        : (order.customerName?.isNotEmpty == true ? order.customerName! : order.orderNumber),
                    subtitle: [
                      _timeFormat.format(order.createdAt.toLocal()),
                      '${order.items.length} ta taom',
                      if (order.waiter != null) order.waiter!.fullName,
                      if (!dineIn)
                        order.isCourierAssignmentPending
                            ? '${order.courier?.fullName ?? ''} (kutilmoqda)'
                            : (order.courier?.fullName ?? 'Kuryer tayinlanmagan'),
                    ].join(' · '),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.format(order.grandTotal, Currency.uzs),
                          style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        RestaurantOrderStatusBadge(status: order.status),
                      ],
                    ),
                    onTap: () => _openDetail(context, ref, order),
                  ).animate().fadeIn(delay: (25 * (index % 12)).ms, duration: AppMotion.standard);
                },
              ),
      ),
    );

    final fab = canCreate
        ? FloatingActionButton(onPressed: () => _openCreate(context, ref), child: const Icon(Icons.add_rounded))
        : null;

    if (!showAppBar) {
      return Scaffold(backgroundColor: Colors.transparent, body: body, floatingActionButton: fab);
    }
    return DashPage(title: l10n.navRestaurantOrders, floatingActionButton: fab, body: body);
  }
}
