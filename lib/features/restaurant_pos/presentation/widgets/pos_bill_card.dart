import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item.dart';
import 'package:bsmart/features/restaurant_orders/domain/restaurant_order_status_actions.dart';
import 'package:bsmart/features/restaurant_orders/presentation/widgets/restaurant_order_status_badge.dart';
import 'package:bsmart/features/restaurant_pos/presentation/providers/restaurant_pos_providers.dart';
import 'package:bsmart/features/restaurant_pos/presentation/widgets/pos_table_card.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

double _round2(double v) => (v * 100).roundToDouble() / 100;

/// The bill's payable total for a given discount — same math as the server's grand total and the
/// checkout (each percent is taken off the discounted food total, then added).
double payableFor(RestaurantOrder order, double discount, {bool service = true, bool waiter = true}) {
  final pre = (order.subtotal - discount).clamp(0, double.infinity).toDouble();
  final s = service ? _round2(pre * order.serviceChargePercent / 100) : 0;
  final w = waiter ? _round2(pre * order.waiterCommissionPercent / 100) : 0;
  return _round2(pre + s + w);
}

String statusActionLabel(BuildContext context, RestaurantOrderStatus status) => switch (status) {
  RestaurantOrderStatus.preparing => context.l10n.restActionPreparing,
  RestaurantOrderStatus.ready => context.l10n.restActionReady,
  RestaurantOrderStatus.served => context.l10n.restActionServed,
  RestaurantOrderStatus.delivered => context.l10n.restActionDelivered,
  RestaurantOrderStatus.cancelled => context.l10n.restCancelOrder,
  RestaurantOrderStatus.newOrder => status.label,
};

/// How many portions of [item] to take off (1..[max]); null = cancelled.
Future<int?> showRemoveDishSheet(BuildContext context, RestaurantOrderItem item, int max, bool kitchenNotified) {
  return showModalBottomSheet<int>(
    context: context,
    builder: (context) => _RemoveDishSheet(item: item, max: max, kitchenNotified: kitchenNotified),
  );
}

/// Asks how many portions of [item] to take off [order] (owner/admin) — null when the user backed
/// out, or when it's the order's last dish (that's cancelling the whole order; a snackbar says so).
Future<int?> pickDishRemoval(BuildContext context, RestaurantOrder order, RestaurantOrderItem item) async {
  final max = item.quantity < order.unitCount - 1 ? item.quantity : order.unitCount - 1;
  if (max < 1) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.rposLastItem)));
    return null;
  }
  final kitchenNotified = item.kitchenSent && order.status != RestaurantOrderStatus.served;
  return showRemoveDishSheet(context, item, max, kitchenNotified);
}

class _RemoveDishSheet extends StatefulWidget {
  const _RemoveDishSheet({required this.item, required this.max, required this.kitchenNotified});

  final RestaurantOrderItem item;
  final int max;
  final bool kitchenNotified;

  @override
  State<_RemoveDishSheet> createState() => _RemoveDishSheetState();
}

class _RemoveDishSheetState extends State<_RemoveDishSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.max > 1 ? '${widget.item.productName} · ×${widget.item.quantity}' : l10n.rposRemoveOne(widget.item.productName),
              style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (widget.max > 1) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.rposRemoveHowMany,
                      style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700),
                    ),
                  ),
                  DashStepper(
                    value: '$_quantity',
                    onMinus: () => setState(() => _quantity = (_quantity - 1).clamp(1, widget.max)),
                    onPlus: () => setState(() => _quantity = (_quantity + 1).clamp(1, widget.max)),
                  ),
                ],
              ),
            ],
            if (widget.kitchenNotified) ...[
              const SizedBox(height: 10),
              Text(
                l10n.rposKitchenNotified,
                style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(_quantity),
                    style: FilledButton.styleFrom(backgroundColor: error, minimumSize: const Size.fromHeight(50)),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.rposRemove),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One bill at the Kassa: its dishes (each with a bin), "add dishes", the kitchen status button,
/// a discount, the payable total, "To'lovga o'tish", and cancelling the bill.
class PosBillCard extends StatefulWidget {
  const PosBillCard({
    required this.order,
    required this.role,
    required this.userId,
    required this.now,
    required this.busy,
    required this.onAddDishes,
    required this.onRemove,
    required this.onStatus,
    required this.onPay,
    super.key,
  });

  final RestaurantOrder order;
  final UserRole role;
  final String userId;
  final DateTime now;
  final bool busy;
  final VoidCallback onAddDishes;
  final void Function(RestaurantOrderItem item, int quantity) onRemove;
  final ValueChanged<RestaurantOrderStatus> onStatus;
  final ValueChanged<double> onPay;

  @override
  State<PosBillCard> createState() => _PosBillCardState();
}

class _PosBillCardState extends State<PosBillCard> {
  late final TextEditingController _discount = TextEditingController(
    text: widget.order.discount > 0 ? _plain(widget.order.discount) : '',
  );

  static String _plain(double v) => v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _discount.dispose();
    super.dispose();
  }

  double get _discountValue =>
      (double.tryParse(_discount.text.trim().replaceAll(',', '.')) ?? 0).clamp(0, widget.order.subtotal).toDouble();

  Future<void> _remove(RestaurantOrderItem item) async {
    final quantity = await pickDishRemoval(context, widget.order, item);
    if (quantity != null) widget.onRemove(item, quantity);
  }

  Future<void> _cancel() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restCancelOrderTitle),
        content: Text(l10n.rposCancelConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.restCancelOrder),
          ),
        ],
      ),
    );
    if (ok == true) widget.onStatus(RestaurantOrderStatus.cancelled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final order = widget.order;
    String money(double v) => CurrencyFormatter.format(v, Currency.uzs);
    final actions = getStatusActions(order, widget.role, widget.userId);
    final forward = actions.where((s) => s != RestaurantOrderStatus.cancelled).toList();
    final canCancel = actions.contains(RestaurantOrderStatus.cancelled);
    final canAdd = canAddItems(order, widget.role, widget.userId);
    final canRemove = canRemoveItems(order, widget.role);
    final discount = _discountValue;
    final pre = (order.subtotal - discount).clamp(0, double.infinity).toDouble();
    final service = _round2(pre * order.serviceChargePercent / 100);
    final waiter = _round2(pre * order.waiterCommissionPercent / 100);
    final payable = payableFor(order, discount);
    final tint = order.status == RestaurantOrderStatus.served
        ? posTableColor(PosTableState.unpaid)
        : order.status == RestaurantOrderStatus.ready
        ? posTableColor(PosTableState.ready)
        : null;

    return DashCard(
      outlineColor: tint,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 6),
              RestaurantOrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  order.isTakeaway
                      ? l10n.rposTakeaway
                      : order.waiter != null
                      ? order.waiter!.fullName
                      : l10n.rposTakenAtCashier,
                  style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
              ElapsedLabel(since: order.createdAt, now: widget.now),
            ],
          ),
          if (order.status == RestaurantOrderStatus.served) ...[
            const SizedBox(height: 8),
            _Note(text: l10n.rposServedUnpaid, color: posTableColor(PosTableState.unpaid)),
          ],
          if (order.isTakeaway && order.kitchenHeld) ...[
            const SizedBox(height: 8),
            _Note(text: l10n.rposTakeawayHeld, color: const Color(0xFFD9822B)),
          ],
          const SizedBox(height: 10),
          for (final (i, item) in order.items.indexed) ...[
            if (i > 0) Divider(height: 1, color: colors.outline),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${item.quantity}×',
                      style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        if (item.notes != null && item.notes!.isNotEmpty)
                          Text(
                            item.notes!,
                            style: const TextStyle(
                              color: Color(0xFFB4690E),
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        if (!item.kitchenSent && !order.isTakeaway)
                          Text(
                            l10n.rposNotSentToKitchen,
                            style: TextStyle(color: colors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    money(item.total),
                    style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  if (canRemove)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '${l10n.rposRemove}: ${item.productName}',
                      onPressed: widget.busy ? null : () => _remove(item),
                      icon: Icon(Icons.delete_outline_rounded, color: colors.textMuted),
                    ),
                ],
              ),
            ),
          ],
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _Note(text: order.notes!, color: const Color(0xFFB4690E)),
          ],
          // Stacked full width: the labels ("Tayyorlashni boshlash") don't fit side by side on a phone.
          if (canAdd) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: widget.busy ? null : widget.onAddDishes,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.rposAddDishes),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
            ),
          ],
          for (final status in forward) ...[
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: widget.busy ? null : () => widget.onStatus(status),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
              child: Text(statusActionLabel(context, status)),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: DashColors.inset(context), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                BillRow(label: l10n.commonSubtotal, value: money(order.subtotal), muted: true),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.commonDiscount,
                        style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: TextField(
                        controller: _discount,
                        enabled: !widget.busy,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '0',
                          isDense: true,
                          filled: true,
                          fillColor: DashColors.card(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (order.serviceChargePercent > 0) ...[
                  const SizedBox(height: 6),
                  BillRow(
                    label: l10n.restServiceChargeWith(_plain(order.serviceChargePercent)),
                    value: '+${money(service)}',
                    muted: true,
                  ),
                ],
                if (order.waiterCommissionPercent > 0) ...[
                  const SizedBox(height: 6),
                  BillRow(
                    label: l10n.restWaiterCommissionWith(_plain(order.waiterCommissionPercent)),
                    value: '+${money(waiter)}',
                    muted: true,
                  ),
                ],
                const SizedBox(height: 10),
                DashedDivider(color: colors.outline),
                const SizedBox(height: 10),
                BillRow(label: l10n.rposToPay, value: money(payable), strong: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.busy ? null : () => widget.onPay(discount),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              textStyle: const TextStyle(fontFamily: BrandTheme.fontFamily, fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
            icon: widget.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Icon(Icons.payments_rounded),
            label: Text(l10n.rposPay),
          ),
          if (order.type == RestaurantOrderType.dineIn) ...[
            const SizedBox(height: 6),
            Text(
              l10n.rposPayHint,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
          if (canCancel)
            TextButton(
              onPressed: widget.busy ? null : _cancel,
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(l10n.restCancelOrder),
            ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
    );
  }
}
