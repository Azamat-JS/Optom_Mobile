import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/currency_toggle.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/income_debt_bar_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/payment_breakdown_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/sales_trend_chart.dart';
import 'package:bsmart/features/stores/presentation/widgets/store_switcher.dart';
import 'package:bsmart/shared/widgets/settings_action_button.dart';

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
    final l10n = context.l10n;

    final roleLabel = switch (role) {
      UserRole.seller || UserRole.sellerAdmin => UserRole.seller.localizedLabel(l10n),
      UserRole.retailer || UserRole.retailerAdmin => UserRole.retailer.localizedLabel(l10n),
      _ => '',
    };
    // Stores/staff management is owner-only server-side (`assertIsOwner` in
    // both `store.service.ts`/`admin.service.ts`) — locked staff never see
    // these nav entries or the branch switcher, matching that enforcement.
    final isOwner = !(authState?.session?.isStaff ?? true);
    // Restaurant-only nav (Phase 4): tables/order-board are operational —
    // owner AND admin see them, mirroring `RestaurantTableController`'s own
    // non-owner-only access. Waiter/Courier *account management* stays
    // owner-only below, matching `assertIsRestaurantOwner`/
    // `assertCanManageCouriers`'s exact-role checks server-side.
    final isRestaurant = user?.businessType == BusinessType.restaurant;
    final courierFeatureEnabled = user?.courierFeatureEnabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('bsmart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.point_of_sale_outlined),
            tooltip: l10n.navPos,
            onPressed: () => context.push(RouteNames.pos),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: l10n.navOrders,
            onPressed: () => context.push(RouteNames.orders),
          ),
          PopupMenuButton<String>(
            onSelected: (route) => context.push(route),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: RouteNames.products,
                child: ListTile(leading: const Icon(Icons.inventory_2_outlined), title: Text(l10n.navProducts)),
              ),
              PopupMenuItem(
                value: RouteNames.customers,
                child: ListTile(leading: const Icon(Icons.groups_outlined), title: Text(l10n.navCustomers)),
              ),
              PopupMenuItem(
                value: RouteNames.sales,
                child: ListTile(leading: const Icon(Icons.history), title: Text(l10n.navSalesHistory)),
              ),
              PopupMenuItem(
                value: RouteNames.debts,
                child: ListTile(leading: const Icon(Icons.receipt_long), title: Text(l10n.navDebts)),
              ),
              // Reports/work-day are @Roles(SELLER, RETAILER) with RolesGuard's
              // admin-inherits-parent-role logic — staff see this too, unlike
              // Expenditures below (owner-only, enforced server-side).
              PopupMenuItem(
                value: RouteNames.reports,
                child: ListTile(leading: const Icon(Icons.bar_chart_outlined), title: Text(l10n.navReports)),
              ),
              // Live courier map: owners once SUPER_ADMIN enabled couriers; store admins always
              // (their session doesn't carry the owner's flag — an empty map just says so).
              if (!isOwner || courierFeatureEnabled)
                PopupMenuItem(
                  value: RouteNames.fleetMap,
                  child: ListTile(leading: const Icon(Icons.map_outlined), title: Text(l10n.navFleetMap)),
                ),
              if (isRestaurant) ...[
                PopupMenuItem(
                  value: RouteNames.restaurantOrders,
                  child: ListTile(leading: const Icon(Icons.dining_outlined), title: Text(l10n.navRestaurantOrders)),
                ),
                PopupMenuItem(
                  value: RouteNames.restaurantTables,
                  child: ListTile(leading: const Icon(Icons.table_restaurant_outlined), title: Text(l10n.navTables)),
                ),
              ],
              if (isOwner) ...[
                PopupMenuItem(
                  value: RouteNames.stores,
                  child: ListTile(leading: const Icon(Icons.storefront_outlined), title: Text(l10n.navStores)),
                ),
                PopupMenuItem(
                  value: RouteNames.admins,
                  child: ListTile(leading: const Icon(Icons.badge_outlined), title: Text(l10n.navStaff)),
                ),
                if (isRestaurant)
                  PopupMenuItem(
                    value: RouteNames.waiters,
                    child: ListTile(leading: const Icon(Icons.room_service_outlined), title: Text(l10n.navWaiters)),
                  ),
                if (courierFeatureEnabled)
                  PopupMenuItem(
                    value: RouteNames.couriers,
                    child: ListTile(leading: const Icon(Icons.moped_outlined), title: Text(l10n.navCouriers)),
                  ),
                PopupMenuItem(
                  value: RouteNames.expenditures,
                  child: ListTile(leading: const Icon(Icons.account_balance_wallet_outlined), title: Text(l10n.navExpenditures)),
                ),
              ],
            ],
          ),
          const SettingsActionButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.commonLogout,
            onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.homeWelcome(user?.fullName ?? ''),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isOwner) const StoreSwitcher(),
              ],
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
                Text(l10n.homeStatistics, style: Theme.of(context).textTheme.titleMedium),
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
                    Text(l10n.homeStatsLoadFailed),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(dashboardProvider),
                      child: Text(l10n.commonRetry),
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
    final l10n = context.l10n;
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
              label: l10n.homeTodaySales,
              value: CurrencyFormatter.format(todaySales.amount, currency),
              subtitle: l10n.homeSalesCount(todaySales.count),
              icon: Icons.today_outlined,
            ),
            KpiCard(
              label: l10n.homeTotalSales,
              value: CurrencyFormatter.format(totalSales.amount, currency),
              subtitle: l10n.homeSalesCount(totalSales.count),
              icon: Icons.bar_chart_outlined,
            ),
            if (wholesaler != null) ...[
              KpiCard(
                label: l10n.homeOutstandingDebt,
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
                label: l10n.homeReceivedPayments,
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
                label: l10n.homeCustomerDebts,
                value: CurrencyFormatter.format(
                  currency == Currency.uzs ? retailer.customerDebts.uzs.balance : retailer.customerDebts.usd.balance,
                  currency,
                ),
                icon: Icons.receipt_long_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              KpiCard(
                label: l10n.homeWholesalerDebts,
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
