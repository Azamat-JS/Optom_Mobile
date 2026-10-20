import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/reports/domain/entities/report_period.dart';
import 'package:bsmart/features/reports/presentation/providers/best_selling_products_notifier.dart';
import 'package:bsmart/features/reports/presentation/providers/reports_provider.dart';
import 'package:bsmart/features/reports/presentation/providers/work_day_notifier.dart';
import 'package:bsmart/features/reports/presentation/widgets/sales_amount_chart.dart';
import 'package:bsmart/features/reports/presentation/widgets/work_day_card.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// The Reports hub ("Hisobotlar") — period-comparison stats, a selectable-
/// window sales chart, best-selling products (reused from Milestone 2), and
/// the "Ish kuni" (work day) shift + Excel export card. Distinct from
/// `features/dashboard`'s fixed-window home screen — this is the
/// period-filterable sibling the original plan calls for.
///
/// Phase 9 U4a (Revolut / Stripe references): large title on the grey page,
/// pill toggles for the period and currency, the revenue figure with its
/// chart in one card, then tiles, the ranked top products and the shift card.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final period = ref.watch(selectedReportPeriodProvider);
    final currency = ref.watch(selectedReportCurrencyProvider);
    final reportsAsync = ref.watch(reportsProvider);
    final workDayAsync = ref.watch(workDayProvider);
    final bestSellingAsync = ref.watch(bestSellingProductsProvider);

    void showError(Object e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonErrorWith('$e'))));
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: DashColors.page(context),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            onRefresh: () async {
              await Future.wait([
                ref.read(reportsProvider.notifier).refresh(),
                ref.read(workDayProvider.notifier).refresh(),
                ref.read(bestSellingProductsProvider.notifier).refresh(),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Row(
                  children: [
                    DashRoundButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    PillToggle<Currency>(
                      values: const [Currency.uzs, Currency.usd],
                      selected: currency,
                      label: (c) => c.name.toUpperCase(),
                      onChanged: (c) => ref.read(selectedReportCurrencyProvider.notifier).state = c,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 18, 4, 14),
                  child: Text(
                    l10n.reportsTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                PillToggle<ReportPeriod>(
                  values: ReportPeriod.values,
                  selected: period,
                  label: (p) => p.label,
                  expand: true,
                  onChanged: (p) => ref.read(selectedReportPeriodProvider.notifier).state = p,
                ),
                const SizedBox(height: 14),
                reportsAsync.when(
                  skipLoadingOnRefresh: true,
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => DashCard(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 40, color: colors.textMuted),
                        const SizedBox(height: 8),
                        Text(l10n.commonErrorWith('$error'), textAlign: TextAlign.center),
                        TextButton(onPressed: () => ref.invalidate(reportsProvider), child: Text(l10n.commonRetry)),
                      ],
                    ),
                  ),
                  data: (data) => _ReportsBody(data: data, currency: currency),
                ),
                DashSectionTitle(l10n.reportsTopProducts),
                bestSellingAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Text(l10n.commonErrorWith('$error')),
                  data: (products) => DashCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: products.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            child: Center(
                              child: Text(l10n.commonNoData, style: TextStyle(color: colors.textMuted)),
                            ),
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < products.length; i++) ...[
                                if (i > 0) Divider(height: 1, indent: 72, color: colors.outline),
                                _TopProductRow(rank: i + 1, product: products[i]),
                              ],
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 22),
                WorkDayCard(
                  workDay: workDayAsync.valueOrNull,
                  onStart: () async {
                    try {
                      await ref.read(workDayProvider.notifier).start();
                    } catch (e) {
                      showError(e);
                    }
                  },
                  onEnd: () async {
                    try {
                      await ref.read(workDayProvider.notifier).end();
                    } catch (e) {
                      showError(e);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody({required this.data, required this.currency});

  final ReportsData data;
  final Currency currency;

  static final _dayMonth = DateFormat('dd.MM');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    final uzs = currency == Currency.uzs;
    final stats = data.periodStats;
    final revenue = uzs ? stats.totalRevenue.uzs : stats.totalRevenue.usd;
    final newDebts = uzs ? stats.newDebtsCreated.uzs : stats.newDebtsCreated.usd;
    final collected = uzs ? stats.debtPaymentsCollected.uzs : stats.debtPaymentsCollected.usd;
    final outstanding = uzs ? stats.outstandingDebtsAtClose.uzs : stats.outstandingDebtsAtClose.usd;
    final salesChart = uzs ? data.salesChart.salesChart.uzs : data.salesChart.salesChart.usd;
    final byMethod = uzs ? stats.salesByPaymentMethod.uzs : stats.salesByPaymentMethod.usd;
    // `to` is the exclusive end (next midnight), so show the last day inside it.
    final range =
        '${_dayMonth.format(stats.from.toLocal())} – ${_dayMonth.format(stats.to.subtract(const Duration(milliseconds: 1)).toLocal())}';
    String money(double v) => CurrencyFormatter.format(v, currency);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashCard(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportsRevenue,
                style: TextStyle(color: colors.textSecondary, fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  money(revenue),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.reportsSalesChart} · $range',
                style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              SalesAmountChart(points: salesChart, currency: currency),
            ],
          ),
        ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.04, end: 0),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: [
            StatTile(
              icon: Icons.receipt_long_rounded,
              label: l10n.reportsNewDebts,
              value: money(newDebts.amount),
              subtitle: l10n.commonPieces('${newDebts.count}'),
              tint: error,
              index: 0,
            ),
            StatTile(
              icon: Icons.payments_rounded,
              label: l10n.reportsDebtPayments,
              value: money(collected.amount),
              subtitle: l10n.commonPieces('${collected.count}'),
              index: 1,
            ),
            StatTile(
              icon: Icons.account_balance_wallet_rounded,
              label: l10n.reportsOutstanding,
              value: money(outstanding.balance),
              subtitle: l10n.commonPieces('${outstanding.count}'),
              tint: error,
              index: 2,
            ),
            StatTile(
              icon: Icons.point_of_sale_rounded,
              label: l10n.homeCashReceived,
              value: money(byMethod.cash),
              index: 3,
            ),
          ],
        ),
      ],
    );
  }
}

/// "1  [photo]  Name / stock      price" — the best sellers, ranked.
class _TopProductRow extends StatelessWidget {
  const _TopProductRow({required this.rank, required this.product});

  final int rank;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final image = product.primaryImage?.url;
    final top = rank <= 3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: top ? colors.accentText : colors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              color: DashColors.inset(context),
              child: image == null
                  ? Icon(Icons.inventory_2_rounded, color: colors.textMuted, size: 22)
                  : CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Icon(Icons.inventory_2_rounded, color: colors.textMuted, size: 22),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  context.l10n.reportsStockWith(product.stock.toStringAsFixed(0)),
                  style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.format(product.price, product.currency),
            style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
