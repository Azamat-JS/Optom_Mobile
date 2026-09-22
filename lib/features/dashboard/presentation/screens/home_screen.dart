import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/currency_toggle.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/income_debt_bar_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/payment_breakdown_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/sales_trend_chart.dart';

/// The Milestone 1 role-aware dashboard (SELLER/RETAILER + their `_ADMIN`
/// staff) — KPI cards, sales-trend/payment-breakdown/income-debt charts, all
/// switching between UZS/USD via [selectedDashboardCurrencyProvider]. Never
/// sums the two currencies into one figure (see `CLAUDE.md`).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(sessionNotifierProvider).valueOrNull;
    final user = authState?.user;
    final role = authState?.session?.role;
    final dashboardAsync = ref.watch(dashboardProvider);
    final currency = ref.watch(selectedDashboardCurrencyProvider);

    final roleLabel = switch (role) {
      UserRole.seller || UserRole.sellerAdmin => 'Optomchi',
      UserRole.retailer || UserRole.retailerAdmin => "Do'konchi",
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('bsmart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Mahsulotlar',
            onPressed: () => context.push(RouteNames.products),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Buyurtmalar',
            onPressed: () => context.push(RouteNames.orders),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Chiqish',
            onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Xush kelibsiz, ${user?.fullName ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (roleLabel.isNotEmpty || user?.shopName != null) ...[
              const SizedBox(height: 2),
              Text(
                [if (roleLabel.isNotEmpty) roleLabel, if (user?.shopName != null) user!.shopName!].join(' • '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Statistika', style: Theme.of(context).textTheme.titleMedium),
                const CurrencyToggle(),
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
                    const Text('Statistikani yuklab bo\'lmadi'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(dashboardProvider),
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
              data: (data) => _DashboardBody(data: data, currency: currency),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data, required this.currency});

  final DashboardData data;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final todaySales = currency == Currency.uzs ? data.todaySales.uzs : data.todaySales.usd;
    final totalSales = currency == Currency.uzs ? data.totalSales.uzs : data.totalSales.usd;
    final paymentBreakdown = currency == Currency.uzs ? data.paymentBreakdown.uzs : data.paymentBreakdown.usd;
    final salesTrend = currency == Currency.uzs ? data.salesTrend.uzs : data.salesTrend.usd;
    final incomeDebt = currency == Currency.uzs ? data.incomeDebtChart.uzs : data.incomeDebtChart.usd;

    final wholesaler = data.wholesaler;
    final retailer = data.retailer;

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
              label: 'Bugungi savdo',
              value: CurrencyFormatter.format(todaySales.amount, currency),
              subtitle: '${todaySales.count} ta savdo',
              icon: Icons.today_outlined,
            ),
            KpiCard(
              label: 'Jami savdo',
              value: CurrencyFormatter.format(totalSales.amount, currency),
              subtitle: '${totalSales.count} ta savdo',
              icon: Icons.bar_chart_outlined,
            ),
            if (wholesaler != null) ...[
              KpiCard(
                label: 'Qarzdorlik',
                value: CurrencyFormatter.format(
                  currency == Currency.uzs
                      ? wholesaler.outstandingDebts.uzs.balance
                      : wholesaler.outstandingDebts.usd.balance,
                  currency,
                ),
                icon: Icons.receipt_long_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              KpiCard(
                label: "Qabul qilingan to'lovlar",
                value: CurrencyFormatter.format(
                  currency == Currency.uzs
                      ? wholesaler.receivedPayments.allTime.uzs.amount
                      : wholesaler.receivedPayments.allTime.usd.amount,
                  currency,
                ),
                icon: Icons.payments_outlined,
              ),
            ],
            if (retailer != null) ...[
              KpiCard(
                label: 'Mijoz qarzlari',
                value: CurrencyFormatter.format(
                  currency == Currency.uzs ? retailer.customerDebts.uzs.balance : retailer.customerDebts.usd.balance,
                  currency,
                ),
                icon: Icons.receipt_long_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              KpiCard(
                label: 'Optomchi qarzlari',
                value: CurrencyFormatter.format(
                  currency == Currency.uzs
                      ? retailer.wholesalerDebts.uzs.balance
                      : retailer.wholesalerDebts.usd.balance,
                  currency,
                ),
                icon: Icons.local_shipping_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
            ],
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
