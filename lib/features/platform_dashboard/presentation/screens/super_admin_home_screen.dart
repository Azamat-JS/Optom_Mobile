import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/income_debt_bar_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/payment_breakdown_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/sales_trend_chart.dart';
import 'package:bsmart/features/platform_dashboard/presentation/providers/platform_dashboard_notifier.dart';

/// Not fetched from the backend — pure UI state for the UZS/USD toggle,
/// deliberately a separate provider from the operator dashboard's
/// `selectedDashboardCurrencyProvider` (never shown to the same session, but
/// keeping them independent avoids any accidental coupling between features).
final _selectedCurrencyProvider = StateProvider<Currency>((ref) => Currency.uzs);

/// The SUPER_ADMIN "shell" — deliberately just the platform dashboard with
/// an overflow menu for drill-down screens, not a bottom-nav-heavy tab
/// structure (per the plan: "much simpler... list/drill-down console"),
/// mirroring `HomeScreen`'s own dashboard-plus-menu pattern rather than
/// inventing a new navigation shape for one role.
class SuperAdminHomeScreen extends ConsumerWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(platformDashboardProvider);
    final currency = ref.watch(_selectedCurrencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (route) => context.push(route),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: RouteNames.superAdminUsers,
                child: ListTile(leading: Icon(Icons.groups_outlined), title: Text('Foydalanuvchilar')),
              ),
              const PopupMenuItem(
                value: RouteNames.superAdminCategories,
                child: ListTile(leading: Icon(Icons.category_outlined), title: Text('Kategoriyalar')),
              ),
              const PopupMenuItem(
                value: RouteNames.superAdminCatalog,
                child: ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('Katalog nazorati')),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Chiqish',
            onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(platformDashboardProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Platforma statistikasi', style: Theme.of(context).textTheme.titleMedium),
                SegmentedButton<Currency>(
                  segments: const [
                    ButtonSegment(value: Currency.uzs, label: Text('UZS')),
                    ButtonSegment(value: Currency.usd, label: Text('USD')),
                  ],
                  selected: {currency},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) => ref.read(_selectedCurrencyProvider.notifier).state = value.first,
                ),
              ],
            ),
            const SizedBox(height: 12),
            dashboardAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 8),
                    const Text("Statistikani yuklab bo'lmadi"),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(platformDashboardProvider),
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
              data: (data) => _PlatformDashboardBody(data: data, currency: currency),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformDashboardBody extends StatelessWidget {
  const _PlatformDashboardBody({required this.data, required this.currency});

  final PlatformDashboardData data;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final dashboard = data.dashboard;
    final sales = currency == Currency.uzs ? dashboard.sales.uzs : dashboard.sales.usd;
    final totalSellings = currency == Currency.uzs ? dashboard.totalSellings.uzs : dashboard.totalSellings.usd;
    final debtBalance = currency == Currency.uzs
        ? dashboard.debtsTotalBalance.uzs
        : dashboard.debtsTotalBalance.usd;
    final paymentBreakdown = currency == Currency.uzs ? dashboard.paymentBreakdown.uzs : dashboard.paymentBreakdown.usd;
    final salesTrend = currency == Currency.uzs ? dashboard.salesTrend.uzs : dashboard.salesTrend.usd;
    final incomeDebt = currency == Currency.uzs ? data.incomeDebtChart.uzs : data.incomeDebtChart.usd;
    final businessTypes = dashboard.users.businessTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            KpiCard(
              label: 'Faol foydalanuvchilar',
              value: '${dashboard.users.active}',
              icon: Icons.people_outline,
            ),
            KpiCard(
              label: 'Buyurtmalar',
              value: '${dashboard.ordersTotal}',
              icon: Icons.receipt_long_outlined,
            ),
            KpiCard(
              label: 'Optomchilar',
              value: '${dashboard.users.wholesalers}',
              icon: Icons.storefront_outlined,
            ),
            KpiCard(
              label: "Do'konchilar",
              value: '${dashboard.users.retailers}',
              subtitle: '${dashboard.users.customers} ta mijoz',
              icon: Icons.storefront,
            ),
            KpiCard(
              label: 'Jami savdo',
              value: CurrencyFormatter.format(sales.amount, currency),
              subtitle: '${sales.count} ta savdo',
              icon: Icons.bar_chart_outlined,
            ),
            KpiCard(
              label: 'Jami tushum',
              value: CurrencyFormatter.format(totalSellings, currency),
              icon: Icons.payments_outlined,
            ),
            KpiCard(
              label: 'Umumiy qarzdorlik',
              value: CurrencyFormatter.format(debtBalance, currency),
              icon: Icons.receipt_long_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text("Yo'nalishlar bo'yicha do'konchilar", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _BusinessTypeChip(label: "Do'kon", count: businessTypes.general),
            _BusinessTypeChip(label: 'Restoran', count: businessTypes.restaurant),
            _BusinessTypeChip(label: 'Maishiy texnika', count: businessTypes.applianceStore),
            _BusinessTypeChip(label: 'Qurilish mollari', count: businessTypes.constructionTools),
            _BusinessTypeChip(label: "O'yinchoqlar", count: businessTypes.toyStore),
            _BusinessTypeChip(label: 'Avto ehtiyot qismlar', count: businessTypes.autoParts),
            _BusinessTypeChip(label: 'Dorixona', count: businessTypes.pharmacy),
            _BusinessTypeChip(label: 'Kiyim-kechak', count: businessTypes.clothingStore),
          ],
        ),
        const SizedBox(height: 16),
        SalesTrendChart(points: salesTrend, currency: currency),
        const SizedBox(height: 16),
        PaymentBreakdownChart(breakdown: paymentBreakdown),
        const SizedBox(height: 16),
        IncomeDebtBarChart(points: incomeDebt),
      ],
    );
  }
}

class _BusinessTypeChip extends StatelessWidget {
  const _BusinessTypeChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $count'));
  }
}
