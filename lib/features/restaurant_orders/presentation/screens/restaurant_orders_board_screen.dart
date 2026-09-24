import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/presentation/providers/open_restaurant_orders_notifier.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_order_create_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_order_detail_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/widgets/restaurant_order_status_badge.dart';

/// The restaurant-orders board — every open (non-terminal) dine-in/delivery
/// order. Independent from the B2B/B2C `Order`/`Sale` pipeline elsewhere in
/// this app (see `RestaurantOrder`'s own doc comment). Reused as-is by
/// `WaiterHomeScreen`'s "Buyurtmalar" tab and `CourierHomeScreen` (both just
/// embed this screen — the backend already scopes a courier's own query to
/// unclaimed-or-mine delivery orders, so no extra client-side filtering is
/// needed here for that role).
class RestaurantOrdersBoardScreen extends ConsumerWidget {
  const RestaurantOrdersBoardScreen({super.key, this.showAppBar = true});

  /// False when embedded inside a shell that already has its own AppBar
  /// (e.g. `WaiterHomeScreen`'s tab body).
  final bool showAppBar;

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RestaurantOrderCreateScreen()),
    );
    if (created == true) ref.read(openRestaurantOrdersProvider.notifier).refresh();
  }

  void _openDetail(BuildContext context, WidgetRef ref, RestaurantOrder order) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RestaurantOrderDetailScreen(orderId: order.id)))
        .then((_) => ref.read(openRestaurantOrdersProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(openRestaurantOrdersProvider);
    final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
    final role = session?.role;
    final canCreate = role == UserRole.retailer || role == UserRole.retailerAdmin || role == UserRole.waiter;

    final body = ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Xatolik: $error')),
      data: (orders) {
        if (orders.isEmpty) return const Center(child: Text('Ochiq buyurtmalar yo\'q'));
        return RefreshIndicator(
          onRefresh: () => ref.read(openRestaurantOrdersProvider.notifier).refresh(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ListTile(
                  onTap: () => _openDetail(context, ref, order),
                  leading: Icon(
                    order.type == RestaurantOrderType.dineIn ? Icons.table_restaurant_outlined : Icons.delivery_dining,
                  ),
                  title: Text(
                    order.type == RestaurantOrderType.dineIn
                        ? 'Stol: ${order.tableNumber ?? order.table?.name ?? '—'}'
                        : (order.customerName?.isNotEmpty == true ? order.customerName! : order.orderNumber),
                  ),
                  subtitle: Text(
                    [
                      '${order.items.length} ta taom',
                      if (order.waiter != null) order.waiter!.fullName,
                      if (order.type == RestaurantOrderType.delivery)
                        order.isCourierAssignmentPending
                            ? '${order.courier?.fullName ?? ''} (kutilmoqda)'
                            : (order.courier?.fullName ?? 'Kuryer tayinlanmagan'),
                    ].join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(CurrencyFormatter.format(order.grandTotal, Currency.uzs)),
                      const SizedBox(height: 4),
                      RestaurantOrderStatusBadge(status: order.status),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (!showAppBar) {
      return Scaffold(
        body: body,
        floatingActionButton: canCreate
            ? FloatingActionButton(onPressed: () => _openCreate(context, ref), child: const Icon(Icons.add))
            : null,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Restoran buyurtmalari')),
      body: body,
      floatingActionButton: canCreate
          ? FloatingActionButton(onPressed: () => _openCreate(context, ref), child: const Icon(Icons.add))
          : null,
    );
  }
}
