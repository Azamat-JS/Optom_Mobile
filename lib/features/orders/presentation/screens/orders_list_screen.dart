import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';
import 'package:bsmart/features/orders/presentation/widgets/order_status_badge.dart';

/// The backend disambiguates by role server-side by default (see
/// `OrderQuery`'s doc comment) — a SELLER sees incoming B2B orders here,
/// every other role that can only ever *place* one (CUSTOMER — Phase 2 —
/// and WAITER/COURIER staff, who inherit their owner's orders) sees their
/// own outgoing ones. A RETAILER is the one role that plays both sides —
/// sourcing stock from a wholesaler (B2B, outgoing/buyer) *and* fulfilling
/// a CUSTOMER's storefront order (B2C, incoming/seller) — so it alone gets
/// the `view` toggle below, wired to `OrdersListNotifier.setView`.
class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  final _scrollController = ScrollController();
  String? _view;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(ordersListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(sessionNotifierProvider).valueOrNull?.session?.role;
    final isRetailer = role == UserRole.retailer || role == UserRole.retailerAdmin;
    // Whether *this screen instance* is currently showing the seller side of
    // the order graph — true for a SELLER always, and for a RETAILER only
    // while their incoming-orders toggle is selected. Never role-alone —a
    // RETAILER's own `Order.seller`/`.buyer` roles flip per order, not per
    // account (see the `view` toggle doc comment above).
    final isSellerView = role == UserRole.seller || role == UserRole.sellerAdmin || (isRetailer && _view == 'incoming');
    final listState = ref.watch(ordersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSellerView ? 'Kelgan buyurtmalar' : 'Buyurtmalarim'),
        bottom: isRetailer
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Chiqarilgan')),
                      ButtonSegment(value: 'incoming', label: Text('Kelgan')),
                    ],
                    selected: {_view},
                    onSelectionChanged: (selection) {
                      setState(() => _view = selection.first);
                      ref.read(ordersListProvider.notifier).setView(selection.first);
                    },
                  ),
                ),
              )
            : null,
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Xatolik: $error')),
        data: (state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('Buyurtmalar topilmadi'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(ordersListProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: state.items.length + (state.hasNext ? 1 : 0),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final order = state.items[index];
                final counterpart = isSellerView ? order.buyer : order.seller;
                return ListTile(
                  title: Text(order.orderNumber),
                  subtitle: Text(
                    '${counterpart?.fullName ?? ''} • ${order.itemCount} ta mahsulot',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(CurrencyFormatter.format(order.total, order.currency)),
                      const SizedBox(height: 4),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  onTap: () => context.push(RouteNames.orderDetail(order.id)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isRetailer && !isSellerView
          ? FloatingActionButton(
              onPressed: () => context.push(RouteNames.orderNewSellerPicker),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
