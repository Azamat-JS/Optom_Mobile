import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/presentation/screens/restaurant_order_detail_screen.dart';
import 'package:bsmart/features/restaurant_orders/presentation/widgets/restaurant_order_status_badge.dart';
import 'package:bsmart/features/restaurant_pos/presentation/providers/restaurant_pos_providers.dart';
import 'package:bsmart/features/restaurant_pos/presentation/restaurant_pos_actions.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The Kassa's "Boshqa buyurtmalar": unpaid orders that aren't a table card — deliveries and
/// takeaways whose payment was abandoned. Each can be paid here; tapping opens the order (status,
/// courier).
class PosOtherOrdersScreen extends ConsumerStatefulWidget {
  const PosOtherOrdersScreen({super.key});

  @override
  ConsumerState<PosOtherOrdersScreen> createState() => _PosOtherOrdersScreenState();
}

class _PosOtherOrdersScreenState extends ConsumerState<PosOtherOrdersScreen> {
  String? _busyId;

  Future<void> _pay(RestaurantOrder order) async {
    setState(() => _busyId = order.id);
    await payRestaurantOrder(context, ref, order);
    if (mounted) setState(() => _busyId = null);
  }

  Future<void> _open(RestaurantOrder order) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => RestaurantOrderDetailScreen(orderId: order.id)));
    await refreshRestaurantPos(ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final ordersAsync = ref.watch(unpaidRestaurantOrdersProvider);
    final orders = otherPosOrders(ordersAsync.valueOrNull ?? const []);

    return DashPage(
      title: l10n.rposOtherOrders,
      body: RefreshIndicator(
        onRefresh: () => refreshRestaurantPos(ref),
        child: orders.isEmpty
            ? ordersAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        DashEmptyState(icon: Icons.receipt_long_rounded, text: l10n.rposNoOtherOrders),
                      ],
                    )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final delivery = order.type == RestaurantOrderType.delivery;
                  final title = order.isTakeaway
                      ? l10n.rposTakeaway
                      : (order.customerName?.isNotEmpty == true ? order.customerName! : order.orderNumber);
                  return DashCard(
                    onTap: () => _open(order),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              order.isTakeaway
                                  ? Icons.shopping_bag_rounded
                                  : delivery
                                  ? Icons.moped_rounded
                                  : Icons.restaurant_rounded,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                            RestaurantOrderStatusBadge(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            order.orderNumber,
                            if (delivery && order.deliveryAddress != null) order.deliveryAddress!,
                            order.items.map((i) => '${i.productName} ×${i.quantity}').join(', '),
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        if (order.isTakeaway && order.kitchenHeld)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              l10n.rposTakeawayHeld,
                              style: const TextStyle(color: Color(0xFFD9822B), fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                CurrencyFormatter.format(order.grandTotal, Currency.uzs),
                                style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _busyId != null ? null : () => _pay(order),
                              icon: _busyId == order.id
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.payments_rounded),
                              label: Text(l10n.rposPay),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
