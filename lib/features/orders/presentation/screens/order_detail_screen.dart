import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/order_delivery_card.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';
import 'package:bsmart/features/orders/domain/usecases/get_order_usecase.dart';
import 'package:bsmart/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';
import 'package:bsmart/features/orders/presentation/widgets/order_status_badge.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  Order? _order;
  String? _errorMessage;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    final result = await getIt<GetOrderUseCase>().call(widget.orderId);
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      result.fold((order) => _order = order, (failure) => _errorMessage = failure.message);
    });
  }

  Future<void> _updateStatus(OrderStatus status, {String? rejectionReason}) async {
    setState(() => _isBusy = true);
    final result = await getIt<UpdateOrderStatusUseCase>().call(
      widget.orderId,
      UpdateOrderStatusParams(status: status, rejectionReason: rejectionReason),
    );
    if (!mounted) return;
    setState(() => _isBusy = false);
    result.fold(
      (order) {
        setState(() => _order = order);
        // Not `ref.invalidate` — that rebuilds the notifier from scratch via
        // `build()`, which always starts from a *default* `OrderQuery()`
        // (no status/view filter), silently discarding whatever filter the
        // list screen had active (e.g. a RETAILER's "Kelgan" B2C-incoming
        // toggle) even though the toggle button itself stays visually
        // selected — caught live: approving an order from here left the
        // orders list showing "Buyurtmalar topilmadi" while "Kelgan" still
        // looked selected. `refresh()` re-fetches using the notifier's own
        // *current* stored query instead, so any active filter survives.
        ref.read(ordersListProvider.notifier).refresh();
      },
      (failure) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _confirmApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.ordersApproveTitle),
        content: Text(context.l10n.ordersApproveConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonConfirm)),
        ],
      ),
    );
    if (confirmed == true) _updateStatus(OrderStatus.approved);
  }

  Future<void> _rejectWithReason() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.ordersRejectTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: context.l10n.commonReasonOptional, border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(context.l10n.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(context.l10n.commonReject),
          ),
        ],
      ),
    );
    if (reason != null) _updateStatus(OrderStatus.rejected, rejectionReason: reason.isEmpty ? null : reason);
  }

  Future<void> _confirmDeliver() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.ordersDeliveredTitle),
        content: Text(context.l10n.ordersDeliveredConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonConfirm)),
        ],
      ),
    );
    if (confirmed == true) _updateStatus(OrderStatus.delivered);
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    // Per-order, not per-role: a RETAILER is the *seller* side of their own
    // B2C orders from a CUSTOMER, even though their account role is never
    // literally SELLER/SELLER_ADMIN — comparing against `order.seller.id`
    // directly is the only way that works for both B2B and B2C orders (a
    // role-based check here would silently hide every approve/reject/deliver
    // action from a RETAILER fulfilling a storefront order).
    final currentUserId = ref.watch(sessionNotifierProvider).valueOrNull?.session?.userId;
    final isSeller = order != null && currentUserId != null && order.seller?.id == currentUserId;
    // Courier delivery management is allowed for the seller's staff too (backend: RETAILER with
    // admin inheritance), so it compares the *tenant* (owner id), not the logged-in user.
    final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
    final tenantId = session?.managedUserId ?? session?.userId;
    final isSellerTenant = order != null && tenantId != null && order.seller?.id == tenantId;

    return Scaffold(
      appBar: AppBar(title: Text(order?.orderNumber ?? context.l10n.ordersOrder)),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : order == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.orderNumber, style: Theme.of(context).textTheme.titleLarge),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.createdAt.toLocal()}'.split('.').first,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      _buildPartiesCard(order),
                      const SizedBox(height: 16),
                      _buildItemsCard(order),
                      const SizedBox(height: 16),
                      _buildTotalsCard(order),
                      // Courier delivery (only approved/delivered orders can have one).
                      if (order.status == OrderStatus.approved || order.status == OrderStatus.delivered)
                        OrderDeliveryCard(
                          orderId: order.id,
                          canManage: isSellerTenant && order.type == OrderType.b2c,
                          canAssign: order.status == OrderStatus.approved,
                        ),
                      if (order.notes != null || order.deliveryAddress != null) ...[
                        const SizedBox(height: 16),
                        _buildNotesCard(order),
                      ],
                      if (order.rejectionReason != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(context.l10n.ordersRejectionReason(order.rejectionReason ?? '')),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildStatusTimeline(order),
                      if (isSeller && (order.canApproveOrReject || order.canMarkDelivered)) ...[
                        const SizedBox(height: 20),
                        _buildActions(order),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildPartiesCard(Order order) {
    return Card(
      child: Column(
        children: [
          if (order.seller != null)
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(order.seller!.fullName),
              // Deliberately generic, not "Optomchi" (Wholesaler) — the
              // seller side of a B2C order (Phase 2: a CUSTOMER buying from
              // a RETAILER's storefront) is a retailer, not a wholesaler.
              subtitle: Text(context.l10n.ordersSeller),
              dense: true,
            ),
          if (order.buyer != null)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(order.buyer!.fullName),
              subtitle: Text(context.l10n.ordersBuyer),
              dense: true,
            ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Order order) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(context.l10n.commonProducts, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final item in order.items)
            ListTile(
              dense: true,
              title: Text(item.productName),
              subtitle: Text('${item.quantity.toStringAsFixed(0)} × ${CurrencyFormatter.format(item.unitPrice, order.currency)}'),
              trailing: Text(CurrencyFormatter.format(item.total, order.currency)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _totalRow(context.l10n.commonSubtotal, order.subtotal, order.currency),
            if (order.discount > 0) _totalRow(context.l10n.commonDiscount, -order.discount, order.currency),
            const Divider(),
            _totalRow(context.l10n.commonTotal, order.total, order.currency, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double amount, dynamic currency, {bool isBold = false}) {
    final style = isBold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(CurrencyFormatter.format(amount, currency), style: style),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.deliveryAddress != null) ...[
              Text(context.l10n.commonDeliveryAddress, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(order.deliveryAddress!),
              const SizedBox(height: 8),
            ],
            if (order.notes != null) ...[
              Text(context.l10n.commonNote, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(order.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(Order order) {
    if (order.statusHistory.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.ordersHistory, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final entry in order.statusHistory)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4, right: 8),
                      child: Icon(Icons.circle, size: 8),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.toStatus.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${entry.createdAt.toLocal()}'.split('.').first,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (entry.comment != null) Text(entry.comment!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(Order order) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (order.canApproveOrReject) ...[
          FilledButton.icon(
            onPressed: _isBusy ? null : _confirmApprove,
            icon: const Icon(Icons.check),
            label: Text(context.l10n.commonConfirm),
          ),
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _rejectWithReason,
            icon: const Icon(Icons.close),
            label: Text(context.l10n.commonReject),
          ),
        ],
        if (order.canMarkDelivered)
          FilledButton.icon(
            onPressed: _isBusy ? null : _confirmDeliver,
            icon: const Icon(Icons.local_shipping_outlined),
            label: Text(context.l10n.ordersDelivered),
          ),
      ],
    );
  }
}
