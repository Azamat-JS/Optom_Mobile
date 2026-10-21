import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/order_delivery_card.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';
import 'package:bsmart/features/orders/domain/usecases/get_order_usecase.dart';
import 'package:bsmart/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';
import 'package:bsmart/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One order: status, total, parties, items + bill, courier delivery,
/// address/note, status history; the seller approves/rejects/delivers from
/// sticky bottom buttons. Phase 9 U4c2: `DashPage` + cards.
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
          decoration: InputDecoration(labelText: context.l10n.commonReasonOptional),
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

    final l10n = context.l10n;
    final showActions = order != null && isSeller && (order.canApproveOrReject || order.canMarkDelivered);

    return DashPage(
      title: order?.orderNumber ?? l10n.ordersOrder,
      bottomBar: showActions ? _buildActions(order) : null,
      body: _errorMessage != null
          ? DashEmptyState(
              icon: Icons.cloud_off_rounded,
              text: _errorMessage!,
              action: TextButton(onPressed: _load, child: Text(l10n.commonRetry)),
            )
          : order == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.onBrand,
              backgroundColor: AppColors.brandYellow,
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  _buildHeaderCard(order),
                  const SizedBox(height: 12),
                  _buildPartiesCard(order),
                  DashSectionTitle(
                    l10n.commonProducts,
                    trailing: Text(
                      l10n.commonProductCount(order.items.length),
                      style: TextStyle(color: BrandColors.of(context).textMuted, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _buildItemsCard(order),
                  // Courier delivery (only approved/delivered orders can have one).
                  if (order.status == OrderStatus.approved || order.status == OrderStatus.delivered)
                    OrderDeliveryCard(
                      orderId: order.id,
                      canManage: isSellerTenant && order.type == OrderType.b2c,
                      canAssign: order.status == OrderStatus.approved,
                    ),
                  if (order.rejectionReason != null) ...[const SizedBox(height: 12), _buildRejectionCard(order)],
                  if (order.notes != null || order.deliveryAddress != null) ...[
                    const SizedBox(height: 12),
                    _buildNotesCard(order),
                  ],
                  if (order.statusHistory.isNotEmpty) ...[
                    DashSectionTitle(l10n.ordersHistory),
                    _buildStatusTimeline(order),
                  ],
                ],
              ),
            ),
    );
  }

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  Widget _buildHeaderCard(Order order) {
    final colors = BrandColors.of(context);
    return DashCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OrderStatusBadge(status: order.status),
              const Spacer(),
              Text(
                _dateFormat.format(order.createdAt.toLocal()),
                style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(order.total, order.currency),
              style: TextStyle(color: colors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
            ),
          ),
          Text(
            context.l10n.commonProductCount(order.itemCount),
            style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPartiesCard(Order order) {
    final colors = BrandColors.of(context);
    Widget party(IconData icon, String name, String role, {bool highlight = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: highlight ? AppColors.brandYellow : DashColors.inset(context),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 21, color: highlight ? AppColors.onBrand : colors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  role,
                  style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return DashCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Deliberately generic, not "Optomchi" (Wholesaler) — the
          // seller side of a B2C order (Phase 2: a CUSTOMER buying from
          // a RETAILER's storefront) is a retailer, not a wholesaler.
          if (order.seller != null)
            party(Icons.storefront_rounded, order.seller!.fullName, context.l10n.ordersSeller, highlight: true),
          if (order.seller != null && order.buyer != null) Divider(height: 8, indent: 54, color: colors.outline),
          if (order.buyer != null) party(Icons.person_rounded, order.buyer!.fullName, context.l10n.ordersBuyer),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Order order) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    String money(double v) => CurrencyFormatter.format(v, order.currency);
    String qty(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 2);
    return DashCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          for (final (i, item) in order.items.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${qty(item.quantity)} × ${money(item.unitPrice)}',
                        style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  money(item.total),
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          DashedDivider(color: colors.outline),
          const SizedBox(height: 14),
          BillRow(label: l10n.commonSubtotal, value: money(order.subtotal), muted: true),
          if (order.discount > 0) ...[
            const SizedBox(height: 6),
            BillRow(label: l10n.commonDiscount, value: '−${money(order.discount)}', muted: true),
          ],
          const SizedBox(height: 10),
          BillRow(label: l10n.commonTotal, value: money(order.total), strong: true),
        ],
      ),
    );
  }

  Widget _buildRejectionCard(Order order) {
    final error = Theme.of(context).colorScheme.error;
    return DashCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.block_rounded, color: error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.ordersRejectionReason(order.rejectionReason ?? ''),
              style: TextStyle(color: error, fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(Order order) {
    final colors = BrandColors.of(context);
    Widget row(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                Text(
                  value,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return DashCard(
      child: Column(
        children: [
          if (order.deliveryAddress != null)
            row(Icons.location_on_rounded, context.l10n.commonDeliveryAddress, order.deliveryAddress!),
          if (order.notes != null) row(Icons.sticky_note_2_rounded, context.l10n.commonNote, order.notes!),
        ],
      ),
    );
  }

  /// Vertical stepper: a coloured dot per status change, joined by a line.
  Widget _buildStatusTimeline(Order order) {
    final colors = BrandColors.of(context);
    final entries = order.statusHistory;
    return DashCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        children: [
          for (final (i, entry) in entries.indexed)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 18,
                    child: Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
                            color: OrderStatusBadge.colorOf(context, entry.toStatus),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i < entries.length - 1) Expanded(child: Container(width: 2, color: colors.outline)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.toStatus.label,
                            style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _dateFormat.format(entry.createdAt.toLocal()),
                            style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          if (entry.comment != null)
                            Text(entry.comment!, style: TextStyle(color: colors.textSecondary, fontSize: 13.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(Order order) {
    final l10n = context.l10n;
    if (order.canMarkDelivered) {
      return DashBottomButton(
        label: l10n.ordersDelivered,
        icon: Icons.local_shipping_rounded,
        busy: _isBusy,
        onPressed: _confirmDeliver,
      );
    }
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isBusy ? null : _rejectWithReason,
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: shape),
                icon: const Icon(Icons.close_rounded),
                label: Text(l10n.commonReject),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _isBusy ? null : _confirmApprove,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: shape),
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.commonConfirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
