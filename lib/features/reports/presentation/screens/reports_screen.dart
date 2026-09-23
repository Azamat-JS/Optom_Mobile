import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:bsmart/features/reports/domain/entities/report_period.dart';
import 'package:bsmart/features/reports/presentation/providers/best_selling_products_notifier.dart';
import 'package:bsmart/features/reports/presentation/providers/reports_provider.dart';
import 'package:bsmart/features/reports/presentation/providers/work_day_notifier.dart';
import 'package:bsmart/features/reports/presentation/widgets/sales_amount_chart.dart';
import 'package:bsmart/features/reports/presentation/widgets/work_day_card.dart';

/// The Reports hub ("Hisobotlar") — period-comparison stats, a selectable-
/// window sales chart, best-selling products (reused from Milestone 2), and
/// the "Ish kuni" (work day) shift + Excel export card. Distinct from
/// `features/dashboard`'s fixed-window home screen — this is the
/// period-filterable sibling the original plan calls for.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedReportPeriodProvider);
    final currency = ref.watch(selectedReportCurrencyProvider);
    final reportsAsync = ref.watch(reportsProvider);
    final workDayAsync = ref.watch(workDayProvider);
    final bestSellingAsync = ref.watch(bestSellingProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hisobotlar')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(reportsProvider.notifier).refresh(),
            ref.read(workDayProvider.notifier).refresh(),
            ref.read(bestSellingProductsProvider.notifier).refresh(),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<ReportPeriod>(
              segments: [for (final p in ReportPeriod.values) ButtonSegment(value: p, label: Text(p.label))],
              selected: {period},
              showSelectedIcon: false,
              onSelectionChanged: (value) => ref.read(selectedReportPeriodProvider.notifier).state = value.first,
            ),
            const SizedBox(height: 16),
            reportsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('Xatolik: $error')),
              ),
              data: (data) => _ReportsBody(data: data, currency: currency),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Eng ko\'p sotilgan mahsulotlar', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            bestSellingAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('Xatolik: $error'),
              data: (products) => products.isEmpty
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Ma'lumot yo'q"))
                  : Card(
                      child: Column(
                        children: [
                          for (final product in products)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(product.name),
                              trailing: Text(CurrencyFormatter.format(product.price, product.currency)),
                              subtitle: Text('Zaxira: ${product.stock.toStringAsFixed(0)}'),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            WorkDayCard(
              workDay: workDayAsync.valueOrNull,
              onStart: () async {
                try {
                  await ref.read(workDayProvider.notifier).start();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
                  }
                }
              },
              onEnd: () async {
                try {
                  await ref.read(workDayProvider.notifier).end();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsBody extends ConsumerWidget {
  const _ReportsBody({required this.data, required this.currency});

  final ReportsData data;
  final Currency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = data.periodStats;
    final revenue = currency == Currency.uzs ? stats.totalRevenue.uzs : stats.totalRevenue.usd;
    final newDebts = currency == Currency.uzs ? stats.newDebtsCreated.uzs : stats.newDebtsCreated.usd;
    final collected = currency == Currency.uzs ? stats.debtPaymentsCollected.uzs : stats.debtPaymentsCollected.usd;
    final outstanding =
        currency == Currency.uzs ? stats.outstandingDebtsAtClose.uzs : stats.outstandingDebtsAtClose.usd;
    final salesChart = currency == Currency.uzs ? data.salesChart.salesChart.uzs : data.salesChart.salesChart.usd;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Statistika', style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<Currency>(
              segments: const [
                ButtonSegment(value: Currency.uzs, label: Text('UZS')),
                ButtonSegment(value: Currency.usd, label: Text('USD')),
              ],
              selected: {currency},
              showSelectedIcon: false,
              onSelectionChanged: (value) => ref.read(selectedReportCurrencyProvider.notifier).state = value.first,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            KpiCard(
              label: 'Tushum',
              value: CurrencyFormatter.format(revenue, currency),
              icon: Icons.trending_up,
            ),
            KpiCard(
              label: 'Yangi qarzlar',
              value: CurrencyFormatter.format(newDebts.amount, currency),
              subtitle: '${newDebts.count} ta',
              icon: Icons.receipt_long_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            KpiCard(
              label: "Qarz to'lovlari",
              value: CurrencyFormatter.format(collected.amount, currency),
              subtitle: '${collected.count} ta',
              icon: Icons.payments_outlined,
            ),
            KpiCard(
              label: 'Qoldiq qarzdorlik',
              value: CurrencyFormatter.format(outstanding.balance, currency),
              subtitle: '${outstanding.count} ta',
              icon: Icons.account_balance_wallet_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Savdo grafigi', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                SalesAmountChart(points: salesChart),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
