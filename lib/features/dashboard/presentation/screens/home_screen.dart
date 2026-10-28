import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/currency_toggle.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/income_debt_bar_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/payment_breakdown_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/sales_trend_chart.dart';
import 'package:bsmart/features/stores/presentation/widgets/store_switcher.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// The role-aware operator home (SELLER/RETAILER + their `_ADMIN` staff).
///
/// Phase 9 U4a (Plum / Stripe / Mailchimp references): a header with the
/// profile button (→ Settings, which has logout) and the branch switcher; a
/// dark hero card with today's sales, the UZS/USD toggle and "Kassa"; a 2×2
/// grid of tappable figures; a visible grid of every section (it used to
/// hide behind a "⋯" menu); then the trend / payment / income-debt charts.
/// Never sums the two currencies into one figure (see `CLAUDE.md`).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: DashColors.page(context),
        body: const SafeArea(bottom: false, child: _Body()),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(sessionNotifierProvider).valueOrNull;
    final user = authState?.user;
    final role = authState?.session?.role;
    final dashboardAsync = ref.watch(dashboardProvider);
    final currency = ref.watch(selectedDashboardCurrencyProvider);
    final colors = BrandColors.of(context);
    final l10n = context.l10n;

    final roleLabel = switch (role) {
      UserRole.seller || UserRole.sellerAdmin => UserRole.seller.localizedLabel(l10n),
      UserRole.retailer || UserRole.retailerAdmin => UserRole.retailer.localizedLabel(l10n),
      _ => '',
    };
    // Stores/staff management is owner-only server-side (`assertIsOwner` in
    // both `store.service.ts`/`admin.service.ts`) — locked staff never see
    // these entries or the branch switcher, matching that enforcement.
    final isOwner = !(authState?.session?.isStaff ?? true);
    final firstName = user?.firstName.trim() ?? '';
    final initial = firstName.isEmpty ? '?' : firstName.characters.first.toUpperCase();

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
      color: AppColors.onBrand,
      backgroundColor: AppColors.brandYellow,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Material(
                color: AppColors.brandYellow,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.push(RouteNames.settings),
                  child: Tooltip(
                    message: l10n.commonSettings,
                    child: SizedBox(
                      width: 46,
                      height: 46,
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontFamily: BrandTheme.fontFamily,
                            color: AppColors.onBrand,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeHello(firstName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (roleLabel.isNotEmpty || user?.shopName != null)
                      Text(
                        [if (roleLabel.isNotEmpty) roleLabel, if (user?.shopName != null) user!.shopName!].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              if (isOwner) const StoreSwitcher(),
              const SizedBox(width: 6),
              DashRoundButton(
                icon: Icons.settings_outlined,
                tooltip: l10n.commonSettings,
                onTap: () => context.push(RouteNames.settings),
              ),
            ],
          ),
          const SizedBox(height: 16),
          dashboardAsync.when(
            skipLoadingOnRefresh: true,
            loading: () => const _HeroSkeleton(),
            error: (_, _) => DashCard(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(
                children: [
                  Icon(Icons.cloud_off_rounded, size: 40, color: colors.textMuted),
                  const SizedBox(height: 8),
                  Text(l10n.homeStatsLoadFailed, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  TextButton(onPressed: () => ref.invalidate(dashboardProvider), child: Text(l10n.commonRetry)),
                ],
              ),
            ),
            data: (data) => _Hero(data: data, currency: currency),
          ),
          if (dashboardAsync.valueOrNull case final data?) ...[
            const SizedBox(height: 12),
            _Tiles(data: data, currency: currency),
          ],
          DashSectionTitle(l10n.homeSections),
          _Shortcuts(isOwner: isOwner),
          if (dashboardAsync.valueOrNull case final data?) ..._charts(context, data, currency),
        ],
      ),
    );
  }

  List<Widget> _charts(BuildContext context, DashboardData data, Currency currency) {
    final uzs = currency == Currency.uzs;
    return [
      DashSectionTitle(context.l10n.homeStatistics),
      SalesTrendChart(points: uzs ? data.salesTrend.uzs : data.salesTrend.usd, currency: currency),
      const SizedBox(height: 12),
      PaymentBreakdownChart(breakdown: uzs ? data.paymentBreakdown.uzs : data.paymentBreakdown.usd),
      const SizedBox(height: 12),
      IncomeDebtBarChart(points: uzs ? data.incomeDebtChart.uzs : data.incomeDebtChart.usd),
    ];
  }
}

/// Dark card with today's sales (the Plum "Your Plum value" card).
class _Hero extends StatelessWidget {
  const _Hero({required this.data, required this.currency});

  final DashboardData data;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = currency == Currency.uzs ? data.todaySales.uzs : data.todaySales.usd;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, Color(0xFF2A2108)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.homeTodaySales,
                  style: TextStyle(
                    fontFamily: BrandTheme.fontFamily,
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const CurrencyToggle(onDark: true),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(today.amount, currency),
              style: const TextStyle(
                fontFamily: BrandTheme.fontFamily,
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.receipt_rounded, size: 16, color: AppColors.brandYellow),
              const SizedBox(width: 6),
              Text(
                l10n.homeSalesCount(today.count),
                style: const TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  color: AppColors.brandYellow,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push(RouteNames.pos),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.point_of_sale_rounded),
            label: Text(l10n.homeOpenPos),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.05, end: 0, curve: AppMotion.emphasized);
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(26)),
      child: const Center(child: CircularProgressIndicator(color: AppColors.brandYellow)),
    );
  }
}

/// 2×2 figures under the hero; each opens the matching list.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.data, required this.currency});

  final DashboardData data;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final uzs = currency == Currency.uzs;
    final error = Theme.of(context).colorScheme.error;
    String money(double v) => CurrencyFormatter.format(v, currency);
    final total = uzs ? data.totalSales.uzs : data.totalSales.usd;
    final inventory = uzs ? data.inventory.uzs : data.inventory.usd;
    final w = data.wholesaler;
    final r = data.retailer;

    final tiles = <Widget>[
      StatTile(
        icon: Icons.bar_chart_rounded,
        label: l10n.homeTotalSales,
        value: money(total.amount),
        subtitle: l10n.homeSalesCount(total.count),
        onTap: () => context.push(RouteNames.sales),
        index: 0,
      ),
      if (w != null) ...[
        StatTile(
          icon: Icons.receipt_long_rounded,
          label: l10n.homeOutstandingDebt,
          value: money(uzs ? w.outstandingDebts.uzs.balance : w.outstandingDebts.usd.balance),
          tint: error,
          onTap: () => context.push(RouteNames.debts),
          index: 1,
        ),
        StatTile(
          icon: Icons.payments_rounded,
          label: l10n.homeReceivedPayments,
          value: money(uzs ? w.receivedPayments.allTime.uzs.amount : w.receivedPayments.allTime.usd.amount),
          subtitle: l10n.homeAllTime,
          index: 2,
        ),
      ],
      if (r != null) ...[
        StatTile(
          icon: Icons.receipt_long_rounded,
          label: l10n.homeCustomerDebts,
          value: money(uzs ? r.customerDebts.uzs.balance : r.customerDebts.usd.balance),
          tint: error,
          onTap: () => context.push(RouteNames.debts),
          index: 1,
        ),
        StatTile(
          icon: Icons.local_shipping_rounded,
          label: l10n.homeWholesalerDebts,
          value: money(uzs ? r.wholesalerDebts.uzs.balance : r.wholesalerDebts.usd.balance),
          tint: error,
          onTap: () => context.push(RouteNames.debts),
          index: 2,
        ),
      ],
      StatTile(
        icon: Icons.inventory_2_rounded,
        label: l10n.homeInventoryValue,
        value: money(inventory.totalStockValue),
        subtitle: l10n.homeExpectedProfit(money(inventory.expectedProfit)),
        onTap: () => context.push(RouteNames.products),
        index: 3,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: tiles,
    );
  }
}

/// Every section the role can open, as a visible grid.
class _Shortcuts extends ConsumerWidget {
  const _Shortcuts({required this.isOwner});

  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(sessionNotifierProvider).valueOrNull?.user;
    // Restaurant-only (Phase 4): tables/order-board are operational — owner
    // AND admin see them. Waiter/Courier account management stays owner-only,
    // matching `assertIsRestaurantOwner`/`assertCanManageCouriers`.
    final isRestaurant = user?.businessType == BusinessType.restaurant;
    final courierFeatureEnabled = user?.courierFeatureEnabled ?? false;
    void go(String route) => context.push(route);

    final items = <ShortcutTile>[
      ShortcutTile(
        icon: Icons.point_of_sale_rounded,
        label: l10n.navPos,
        highlight: true,
        onTap: () => go(RouteNames.pos),
      ),
      ShortcutTile(icon: Icons.receipt_long_rounded, label: l10n.navOrders, onTap: () => go(RouteNames.orders)),
      ShortcutTile(icon: Icons.inventory_2_rounded, label: l10n.navProducts, onTap: () => go(RouteNames.products)),
      ShortcutTile(icon: Icons.groups_rounded, label: l10n.navCustomers, onTap: () => go(RouteNames.customers)),
      ShortcutTile(icon: Icons.history_rounded, label: l10n.navSalesHistory, onTap: () => go(RouteNames.sales)),
      ShortcutTile(icon: Icons.request_quote_rounded, label: l10n.navDebts, onTap: () => go(RouteNames.debts)),
      // Reports/work-day are @Roles(SELLER, RETAILER) with admin inheritance —
      // staff see them too, unlike Expenditures (owner-only).
      ShortcutTile(icon: Icons.insights_rounded, label: l10n.navReports, onTap: () => go(RouteNames.reports)),
      // Live courier map: owners once SUPER_ADMIN enabled couriers; store admins always.
      if (!isOwner || courierFeatureEnabled)
        ShortcutTile(icon: Icons.map_rounded, label: l10n.navFleetMap, onTap: () => go(RouteNames.fleetMap)),
      if (isRestaurant) ...[
        ShortcutTile(
          icon: Icons.dining_rounded,
          label: l10n.navRestaurantOrders,
          onTap: () => go(RouteNames.restaurantOrders),
        ),
        ShortcutTile(
          icon: Icons.table_restaurant_rounded,
          label: l10n.navTables,
          onTap: () => go(RouteNames.restaurantTables),
        ),
      ],
      if (isOwner) ...[
        ShortcutTile(icon: Icons.storefront_rounded, label: l10n.navStores, onTap: () => go(RouteNames.stores)),
        ShortcutTile(icon: Icons.badge_rounded, label: l10n.navStaff, onTap: () => go(RouteNames.admins)),
        if (isRestaurant)
          ShortcutTile(icon: Icons.room_service_rounded, label: l10n.navWaiters, onTap: () => go(RouteNames.waiters)),
        if (courierFeatureEnabled)
          ShortcutTile(icon: Icons.moped_rounded, label: l10n.navCouriers, onTap: () => go(RouteNames.couriers)),
        // Lead agents (dillers): owner-only, every business type (Phase 10).
        ShortcutTile(icon: Icons.handshake_rounded, label: l10n.navLeadAgents, onTap: () => go(RouteNames.leadAgents)),
        ShortcutTile(
          icon: Icons.account_balance_wallet_rounded,
          label: l10n.navExpenditures,
          onTap: () => go(RouteNames.expenditures),
        ),
      ],
    ];
    // A Wrap rather than a grid: rows take the height of their labels, so a
    // two-line label (or a large text scale) never overflows a fixed cell.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 3 * 6) / 4;
        return Wrap(
          spacing: 6,
          runSpacing: 8,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: width,
                child: items[i]
                    .animate()
                    .fadeIn(delay: (30 * i).ms, duration: AppMotion.standard)
                    .scaleXY(begin: 0.9, end: 1),
              ),
          ],
        );
      },
    );
  }
}
