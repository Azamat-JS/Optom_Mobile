import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/income_debt_bar_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/payment_breakdown_chart.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/sales_trend_chart.dart';
import 'package:bsmart/features/platform_dashboard/domain/entities/platform_dashboard.dart';
import 'package:bsmart/features/platform_dashboard/presentation/providers/platform_dashboard_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Not fetched from the backend — pure UI state for the UZS/USD toggle,
/// deliberately a separate provider from the operator dashboard's
/// `selectedDashboardCurrencyProvider` (never shown to the same session, but
/// keeping them independent avoids any accidental coupling between features).
final _selectedCurrencyProvider = StateProvider<Currency>((ref) => Currency.uzs);

/// The SUPER_ADMIN home. Phase 9 U4c7c: the operator home's layout (U4a) —
/// a header with settings/logout, a dark hero with platform-wide sales and
/// the UZS/USD toggle, 2×2 figures, the drill-down screens as a visible
/// "Bo'limlar" grid (they used to hide behind a "⋯" menu), the user /
/// business-vertical breakdown, then the charts. Never sums the two
/// currencies into one figure.
class SuperAdminHomeScreen extends ConsumerWidget {
  const SuperAdminHomeScreen({super.key});

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
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final user = ref.watch(sessionNotifierProvider).valueOrNull?.user;
    final dashboardAsync = ref.watch(platformDashboardProvider);
    final currency = ref.watch(_selectedCurrencyProvider);
    final firstName = user?.firstName.trim() ?? '';
    final initial = firstName.isEmpty ? '?' : firstName.characters.first.toUpperCase();

    return RefreshIndicator(
      onRefresh: () => ref.read(platformDashboardProvider.notifier).refresh(),
      color: AppColors.onBrand,
      backgroundColor: AppColors.brandYellow,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
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
                    Text(
                      UserRole.superAdmin.localizedLabel(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              DashRoundButton(
                icon: Icons.settings_outlined,
                tooltip: l10n.commonSettings,
                onTap: () => context.push(RouteNames.settings),
              ),
              const SizedBox(width: 8),
              DashRoundButton(
                icon: Icons.logout_rounded,
                tooltip: l10n.commonLogout,
                onTap: () => ref.read(sessionNotifierProvider.notifier).logout(),
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
                  TextButton(onPressed: () => ref.invalidate(platformDashboardProvider), child: Text(l10n.commonRetry)),
                ],
              ),
            ),
            data: (data) => _Hero(dashboard: data.dashboard, currency: currency),
          ),
          if (dashboardAsync.valueOrNull case final data?) ...[
            const SizedBox(height: 12),
            _Tiles(dashboard: data.dashboard, currency: currency),
          ],
          DashSectionTitle(l10n.homeSections),
          const _Shortcuts(),
          if (dashboardAsync.valueOrNull case final data?) ...[
            DashSectionTitle(l10n.navUsers),
            _UsersCard(stats: data.dashboard.users),
            const DashSectionTitle("Yo'nalishlar bo'yicha do'konchilar"),
            _VerticalsCard(counts: data.dashboard.users.businessTypes),
            DashSectionTitle(l10n.homeStatistics),
            ..._charts(data, currency),
          ],
        ],
      ),
    );
  }

  List<Widget> _charts(PlatformDashboardData data, Currency currency) {
    final uzs = currency == Currency.uzs;
    final dashboard = data.dashboard;
    return [
      SalesTrendChart(points: uzs ? dashboard.salesTrend.uzs : dashboard.salesTrend.usd, currency: currency),
      const SizedBox(height: 12),
      PaymentBreakdownChart(breakdown: uzs ? dashboard.paymentBreakdown.uzs : dashboard.paymentBreakdown.usd),
      const SizedBox(height: 12),
      IncomeDebtBarChart(points: uzs ? data.incomeDebtChart.uzs : data.incomeDebtChart.usd),
    ];
  }
}

/// Dark card with platform-wide sales.
class _Hero extends ConsumerWidget {
  const _Hero({required this.dashboard, required this.currency});

  final PlatformDashboard dashboard;
  final Currency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final uzs = currency == Currency.uzs;
    final sales = uzs ? dashboard.sales.uzs : dashboard.sales.usd;
    final totalSellings = uzs ? dashboard.totalSellings.uzs : dashboard.totalSellings.usd;
    TextStyle muted(double size) => TextStyle(
      fontFamily: BrandTheme.fontFamily,
      color: Colors.white.withValues(alpha: 0.72),
      fontSize: size,
      fontWeight: FontWeight.w700,
    );
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
              Expanded(child: Text('Jami savdo', style: muted(16))),
              PillToggle<Currency>(
                values: const [Currency.uzs, Currency.usd],
                selected: currency,
                label: (c) => c == Currency.uzs ? 'UZS' : 'USD',
                onDark: true,
                onChanged: (c) => ref.read(_selectedCurrencyProvider.notifier).state = c,
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(sales.amount, currency),
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
                l10n.homeSalesCount(sales.count),
                style: const TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  color: AppColors.brandYellow,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('Jami tushum', style: muted(14))),
              Text(
                CurrencyFormatter.format(totalSellings, currency),
                style: const TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
      height: 210,
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(26)),
      child: const Center(child: CircularProgressIndicator(color: AppColors.brandYellow)),
    );
  }
}

/// 2×2 figures under the hero.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.dashboard, required this.currency});

  final PlatformDashboard dashboard;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final uzs = currency == Currency.uzs;
    final debt = uzs ? dashboard.debtsTotalBalance.uzs : dashboard.debtsTotalBalance.usd;
    final cash = uzs ? dashboard.cashReceived.uzs : dashboard.cashReceived.usd;
    final card = uzs ? dashboard.cardReceived.uzs : dashboard.cardReceived.usd;
    String money(double v) => CurrencyFormatter.format(v, currency);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        StatTile(
          icon: Icons.people_alt_rounded,
          label: 'Faol foydalanuvchilar',
          value: '${dashboard.users.active}',
          onTap: () => context.push(RouteNames.superAdminUsers),
          index: 0,
        ),
        StatTile(icon: Icons.receipt_long_rounded, label: 'Buyurtmalar', value: '${dashboard.ordersTotal}', index: 1),
        StatTile(
          icon: Icons.receipt_long_rounded,
          label: 'Umumiy qarzdorlik',
          value: money(debt),
          tint: Theme.of(context).colorScheme.error,
          index: 2,
        ),
        StatTile(
          icon: Icons.payments_rounded,
          label: PaymentMethod.cash.label,
          value: money(cash),
          subtitle: '${PaymentMethod.card.label}: ${money(card)}',
          index: 3,
        ),
      ],
    );
  }
}

/// The drill-down screens, as on the operator home.
class _Shortcuts extends StatelessWidget {
  const _Shortcuts();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      ShortcutTile(
        icon: Icons.groups_rounded,
        label: l10n.navUsers,
        highlight: true,
        onTap: () => context.push(RouteNames.superAdminUsers),
      ),
      ShortcutTile(
        icon: Icons.category_rounded,
        label: l10n.navCategories,
        onTap: () => context.push(RouteNames.superAdminCategories),
      ),
      ShortcutTile(
        icon: Icons.inventory_2_rounded,
        label: l10n.navCatalogModeration,
        onTap: () => context.push(RouteNames.superAdminCatalog),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Three sections: a third each, so the long labels don't break mid-word.
        final width = (constraints.maxWidth - 2 * 6) / 3;
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

/// Wholesalers / retailers / customers side by side.
class _UsersCard extends StatelessWidget {
  const _UsersCard({required this.stats});

  final PlatformUserStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    Widget cell(IconData icon, String label, int value) => Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: DashColors.inset(context), borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, size: 21, color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
    return DashCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          cell(Icons.local_shipping_rounded, UserRole.seller.label, stats.wholesalers),
          cell(Icons.storefront_rounded, UserRole.retailer.label, stats.retailers),
          cell(Icons.person_rounded, UserRole.customer.label, stats.customers),
        ],
      ),
    );
  }
}

/// Active retailers per business vertical, with a bar scaled to the largest.
class _VerticalsCard extends StatelessWidget {
  const _VerticalsCard({required this.counts});

  final PlatformBusinessTypeCounts counts;

  int _count(BusinessType type) => switch (type) {
    BusinessType.general => counts.general,
    BusinessType.restaurant => counts.restaurant,
    BusinessType.applianceStore => counts.applianceStore,
    BusinessType.constructionTools => counts.constructionTools,
    BusinessType.toyStore => counts.toyStore,
    BusinessType.autoParts => counts.autoParts,
    BusinessType.pharmacy => counts.pharmacy,
    BusinessType.clothingStore => counts.clothingStore,
  };

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final rows = [for (final t in BusinessType.values) (type: t, count: _count(t))]
      ..sort((a, b) => b.count.compareTo(a.count));
    final max = rows.isEmpty ? 0 : rows.first.count;
    return DashCard(
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.type.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${row.count}',
                  style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: max == 0 ? 0 : row.count / max,
                minHeight: 6,
                backgroundColor: DashColors.inset(context),
                color: AppColors.brandYellow,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
