import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';
import 'package:bsmart/features/orders/presentation/widgets/order_status_badge.dart';

/// The backend disambiguates by role server-side (see `OrderQuery`'s doc
/// comment) — a SELLER sees incoming B2B orders here, a RETAILER sees their
/// own outgoing ones, with no client-side `view` toggle needed in Milestone 3.
class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  final _scrollController = ScrollController();

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
    final listState = ref.watch(ordersListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isRetailer ? 'Buyurtmalarim' : 'Kelgan buyurtmalar')),
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
                final counterpart = isRetailer ? order.seller : order.buyer;
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
      floatingActionButton: isRetailer
          ? FloatingActionButton(
              onPressed: () => context.push(RouteNames.orderNewSellerPicker),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
