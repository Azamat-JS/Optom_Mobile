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
import 'package:bsmart/features/sales/domain/usecases/get_sale_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/sales_list_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_return_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/sale_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// A sale's receipt-like detail — items, totals, payment(s)/debt, and
/// (while [Sale.canReturn]) a "Qaytarish" action. There is no separate
/// `Receipt` model server-side — this screen *is* the receipt, regenerated
/// on demand from `GET /sales/:id` (see `CLAUDE.md`'s reference doc note).
///
/// Phase 9 U4b: a header card with the total (and a success check right
/// after checkout), then receipt-style cards with dashed dividers. Right
/// after checkout the bottom button starts the next sale.
class SaleDetailScreen extends ConsumerStatefulWidget {
  const SaleDetailScreen({super.key, required this.saleId, this.justCreated = false});

  final String saleId;
  final bool justCreated;

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  Sale? _sale;
  String? _errorMessage;

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
                        sale?.saleNumber ?? l10n.salesSale,
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
        bottomNavigationBar: sale == null || (!widget.justCreated && !sale.canReturn)
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    SaleTypeBadge(type: sale.type),
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
