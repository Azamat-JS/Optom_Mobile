import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bsmart/features/sales/domain/usecases/cancel_manual_revenue_usecase.dart';
import 'package:bsmart/features/sales/domain/usecases/get_sale_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_return_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// A sale's receipt-like detail — items, totals, payment(s)/debt, and
/// (while [Sale.canReturn]) a "Qaytarish" action. There is no separate
/// `Receipt` model server-side — this screen *is* the receipt, regenerated
/// on demand from `GET /sales/:id` (see `CLAUDE.md`'s reference doc note).
///
/// Phase 9 U4b: a header card with the total (and a success check right
/// after checkout), then receipt-style cards with dashed dividers. Right
/// after checkout the bottom button starts the next sale.
///
/// A manual revenue (Optom_Savdo "Manual Revenue") has no products: the
/// screen shows what it is instead of a product list, and offers
/// "Bekor qilish" (with a confirmation) instead of a return.
class SaleDetailScreen extends ConsumerStatefulWidget {
  const SaleDetailScreen({super.key, required this.saleId, this.justCreated = false, this.orderLabel});

  final String saleId;
  final bool justCreated;

  /// The restaurant order this sale paid ("Buyurtma #K3F9QX · Olib ketish") — the number the
  /// kitchen calls out, shown big on the receipt.
  final String? orderLabel;

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  Sale? _sale;
  String? _errorMessage;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _errorMessage = null);
    final result = await getIt<GetSaleUseCase>().call(widget.saleId);
    if (!mounted) return;
    result.fold((sale) => setState(() => _sale = sale), (failure) => setState(() => _errorMessage = failure.message));
  }

  Future<void> _openReturn() async {
    final sale = _sale;
    if (sale == null) return;
    final returned = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => SaleReturnScreen(sale: sale)));
    if (returned == true) {
      _load();
      // Keep the app-wide sales history's status pill in step.
      ref.read(salesListProvider.notifier).refresh();
    }
  }

  Future<void> _confirmCancel() async {
    final sale = _sale;
    if (sale == null) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.manualRevenueCancelTitle),
        content: Text(l10n.manualRevenueCancelText(CurrencyFormatter.format(sale.total, sale.currency))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.manualRevenueKeep)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.manualRevenueCancelConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    final result = await getIt<CancelManualRevenueUseCase>().call(sale.id);
    if (!mounted) return;
    setState(() => _isCancelling = false);
    final messenger = ScaffoldMessenger.of(context);
    result.fold(
      (cancelled) {
        setState(() => _sale = cancelled);
        ref.read(salesListProvider.notifier).refresh();
        ref.invalidate(dashboardProvider);
        messenger.showSnackBar(SnackBar(content: Text(l10n.manualRevenueCancelled)));
      },
      // E.g. already cancelled from another device: show why, then reload the real state.
      (failure) {
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final sale = _sale;

    final Widget body;
    if (_errorMessage != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44, color: colors.textMuted),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            TextButton(onPressed: _load, child: Text(l10n.commonRetry)),
          ],
        ),
      );
    } else if (sale == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _receipt(sale);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: DashColors.page(context),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    DashRoundButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sale == null
                            ? l10n.salesSale
                            : sale.isManualRevenue
                            ? l10n.manualRevenueDetailTitle
                            : sale.saleNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
        bottomNavigationBar: sale == null
            ? null
            : sale.canCancel
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: OutlinedButton.icon(
                    key: const Key('manualRevenueCancel'),
                    onPressed: _isCancelling ? null : _confirmCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: _isCancelling
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.block_rounded),
                    label: Text(l10n.manualRevenueCancel),
                  ),
                ),
              )
            : (!widget.justCreated && !sale.canReturn)
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Row(
                    children: [
                      if (sale.canReturn)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openReturn,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            icon: const Icon(Icons.undo_rounded),
                            label: Text(l10n.salesReturn),
                          ),
                        ),
                      if (sale.canReturn && widget.justCreated) const SizedBox(width: 10),
                      if (widget.justCreated)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).maybePop(),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            icon: const Icon(Icons.point_of_sale_rounded),
                            label: Text(l10n.salesNewSale),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _receipt(Sale sale) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    String money(double v) => CurrencyFormatter.format(v, sale.currency);
    String qty(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 3);

    return RefreshIndicator(
      color: AppColors.onBrand,
      backgroundColor: AppColors.brandYellow,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          DashCard(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              children: [
                if (widget.justCreated) ...[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: AppColors.onBrand, size: 38),
                  ).animate().scaleXY(begin: 0.4, end: 1, duration: AppMotion.standard, curve: Curves.easeOutBack),
                  const SizedBox(height: 10),
                  Text(
                    l10n.salesCreated,
                    style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                ],
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    money(sale.total),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                if (widget.orderLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.orderLabel!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    SaleTypeBadge(type: sale.type),
                    if (sale.isManualRevenue) DashTag(label: l10n.manualRevenueTag, color: colors.accentText),
                    SaleStatusBadge(status: sale.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  [
                    if (sale.customer != null) sale.customer!.fullName,
                    _dateFormat.format(sale.createdAt.toLocal()),
                  ].join(' · '),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ).animate().fadeIn(duration: AppMotion.standard),
          if (sale.isManualRevenue) ...[
            const SizedBox(height: 12),
            DashCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: colors.accentText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.manualRevenueDetailHint,
                      style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            DashSectionTitle(
              l10n.commonProducts,
              trailing: Text(
                l10n.commonProductCount(sale.items.length),
                style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w700),
              ),
            ),
            DashCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  for (final (i, item) in sale.items.indexed) ...[
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
                              if (item.returnedQuantity > 0)
                                Text(
                                  l10n.salesReturnedQty(qty(item.returnedQuantity)),
                                  style: TextStyle(color: error, fontSize: 12.5, fontWeight: FontWeight.w700),
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
                  BillRow(label: l10n.commonSubtotal, value: money(sale.subtotal), muted: true),
                  if (sale.discount > 0) ...[
                    const SizedBox(height: 6),
                    BillRow(label: l10n.commonDiscount, value: '−${money(sale.discount)}', muted: true),
                  ],
                  const SizedBox(height: 10),
                  BillRow(label: l10n.commonTotal, value: money(sale.total), strong: true),
                ],
              ),
            ),
          ],
          if (sale.debt != null) ...[
            const SizedBox(height: 12),
            DashCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: error, size: 19),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.salesDebt,
                        style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BillRow(label: l10n.commonPaid, value: money(sale.debt!.paidAmount), muted: true),
                  const SizedBox(height: 6),
                  BillRow(label: l10n.commonBalance, value: money(sale.debt!.balance), strong: true),
                ],
              ),
            ),
          ],
          if (sale.payments.isNotEmpty) ...[
            DashSectionTitle(l10n.salesPayments),
            DashCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  for (final (i, payment) in sale.payments.indexed) ...[
                    if (i > 0) const SizedBox(height: 8),
                    BillRow(label: payment.method.label, value: money(payment.amount)),
                  ],
                ],
              ),
            ),
          ],
          if (sale.notes != null && sale.notes!.isNotEmpty) ...[
            DashSectionTitle(l10n.commonNote),
            DashCard(
              child: Text(
                sale.notes!,
                style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
