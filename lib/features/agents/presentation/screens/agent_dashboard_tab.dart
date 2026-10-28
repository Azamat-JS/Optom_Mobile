import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_dashboard_providers.dart';
import 'package:bsmart/features/agents/presentation/providers/lead_agent_providers.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_staff_list_screen.dart';
import 'package:bsmart/features/agents/presentation/screens/lead_account_screen.dart';
import 'package:bsmart/features/agents/presentation/screens/received_transfers_screen.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bsmart/features/dashboard/presentation/widgets/currency_toggle.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Agent home: who you work for, sales today / 30 days and open customer debts (a staff agent's
/// own); a lead agent also sees what it owes the owner, what it holds, and its net profit.
class AgentDashboardTab extends ConsumerWidget {
  const AgentDashboardTab({required this.onOpenTab, super.key});

  /// Switches the shell's tab (2 = sales, 3 = debtors).
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isLead = ref.watch(sessionNotifierProvider).valueOrNull?.session?.role == UserRole.leadAgent;
    final summaryAsync = ref.watch(agentSummaryProvider);

    Future<void> refresh() async {
      ref.invalidate(agentProfileProvider);
      ref.invalidate(agentProfitProvider);
      if (isLead) ref.invalidate(leadAccountProvider);
      await ref.read(agentSummaryProvider.notifier).refresh();
    }

    return RefreshIndicator(
      color: AppColors.onBrand,
      backgroundColor: AppColors.brandYellow,
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _ProfileCard(),
          const SizedBox(height: 12),
          const Align(alignment: Alignment.centerLeft, child: CurrencyToggle()),
          const SizedBox(height: 12),
          summaryAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
            data: (summary) => _StatGrid(summary: summary, isLead: isLead, onOpenTab: onOpenTab),
          ),
          if (isLead) ...[
            DashSectionTitle(l10n.homeSections),
            const _LeadShortcuts(),
            DashSectionTitle(l10n.agentProfitTitle),
            const _ProfitCard(),
          ],
        ],
      ),
    );
  }
}

/// Lead agent only: its account with the owner (badged while requests wait), received transfers,
/// and its staff agents.
class _LeadShortcuts extends ConsumerWidget {
  const _LeadShortcuts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pending = ref.watch(leadAccountProvider).valueOrNull;
    final waiting = pending != null &&
        (pending.pendingReturns > 0 || pending.pendingPayments.uzs > 0 || pending.pendingPayments.usd > 0);
    void open(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    return Row(
      children: [
        Expanded(
          child: ShortcutTile(
            icon: Icons.account_balance_wallet_rounded,
            label: l10n.agentAccountTitle,
            highlight: waiting,
            onTap: () => open(const LeadAccountScreen()),
          ),
        ),
        Expanded(
          child: ShortcutTile(
            icon: Icons.local_shipping_rounded,
            label: l10n.agentTransfersTitle,
            onTap: () => open(const ReceivedTransfersScreen()),
          ),
        ),
        Expanded(
          child: ShortcutTile(
            icon: Icons.groups_rounded,
            label: l10n.agentStaffTitle,
            onTap: () => open(const AgentStaffListScreen()),
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final profile = ref.watch(agentProfileProvider).valueOrNull;
    final fallback = ref.watch(sessionNotifierProvider).valueOrNull?.user;
    final user = profile ?? fallback;
    if (user == null) return const SizedBox.shrink();

    final owner = user.agentOwner;
    final worksFor = user.role == UserRole.leadAgent && owner != null
        ? l10n.agentLeadOf(owner.shopName?.isNotEmpty == true ? owner.shopName! : owner.fullName)
        : user.role == UserRole.agent && user.owner != null
            ? l10n.agentStaffOf(user.owner!.fullName)
            : null;

    return DashCard(
      child: Row(
        children: [
          DashAvatar(name: user.firstName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.agentHello(user.firstName),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  [user.role.localizedLabel(l10n), ?worksFor].join(' · '),
                  style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends ConsumerWidget {
  const _StatGrid({required this.summary, required this.isLead, required this.onOpenTab});

  final AgentSummary summary;
  final bool isLead;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currency = ref.watch(selectedDashboardCurrencyProvider);
    final error = Theme.of(context).colorScheme.error;
    String money(MoneyByCurrency m) => CurrencyFormatter.format(currency == Currency.uzs ? m.uzs : m.usd, currency);

    final tiles = <Widget>[
      StatTile(
        icon: Icons.today_rounded,
        label: isLead ? l10n.agentTodaySales : l10n.agentMyTodaySales,
        value: money(summary.todayRevenue),
        subtitle: l10n.agentSalesCount(summary.todayCount),
        onTap: () => onOpenTab(2),
        index: 0,
      ),
      StatTile(
        icon: Icons.bar_chart_rounded,
        label: isLead ? l10n.agentMonthSales : l10n.agentMyMonthSales,
        value: money(summary.monthRevenue),
        subtitle: l10n.agentSalesCount(summary.monthCount),
        onTap: () => onOpenTab(2),
        index: 1,
      ),
      StatTile(
        icon: Icons.receipt_long_rounded,
        label: isLead ? l10n.agentCustomersOwe : l10n.agentMyDebtsGiven,
        value: money(summary.customerDebt),
        subtitle: l10n.agentOpenDebts(summary.openDebtCount),
        tint: error,
        onTap: () => onOpenTab(3),
        index: 2,
      ),
      if (summary.debtToOwner != null)
        StatTile(
          icon: Icons.account_balance_wallet_rounded,
          label: l10n.agentOwedToOwner,
          value: money(summary.debtToOwner!),
          tint: error,
          index: 3,
        ),
      if (summary.stockValue != null)
        StatTile(
          icon: Icons.inventory_2_rounded,
          label: l10n.agentStockValue,
          value: money(summary.stockValue!),
          onTap: () => onOpenTab(1),
          index: 4,
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

/// The lead agent's net profit for a window, in the currency the toggle shows.
class _ProfitCard extends ConsumerStatefulWidget {
  const _ProfitCard();

  @override
  ConsumerState<_ProfitCard> createState() => _ProfitCardState();
}

class _ProfitCardState extends ConsumerState<_ProfitCard> {
  AgentProfitPeriod _period = AgentProfitPeriod.last7;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final currency = ref.watch(selectedDashboardCurrencyProvider);
    final profitAsync = ref.watch(agentProfitProvider(_period));
    String money(double v) => CurrencyFormatter.format(v, currency);

    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PillToggle<AgentProfitPeriod>(
            values: AgentProfitPeriod.values,
            selected: _period,
            expand: true,
            label: (p) => switch (p) {
              AgentProfitPeriod.today => l10n.agentProfitToday,
              AgentProfitPeriod.last7 => l10n.agentProfit7,
              AgentProfitPeriod.last30 => l10n.agentProfit30,
            },
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(height: 16),
          profitAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text(l10n.commonErrorWith('$error')),
            data: (profit) {
              final stats = currency == Currency.uzs ? profit.uzs : profit.usd;
              final loss = stats.netProfit < 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    money(stats.netProfit),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: loss ? Theme.of(context).colorScheme.error : colors.success,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BillRow(label: l10n.agentProfitRevenue, value: money(stats.revenue)),
                  BillRow(label: l10n.agentProfitCost, value: money(stats.cost), muted: true),
                  if (stats.pendingProfit > 0)
                    BillRow(label: l10n.agentProfitPending, value: money(stats.pendingProfit), muted: true),
                  if (stats.ownDebts > 0) BillRow(label: l10n.agentOwedToOwner, value: money(stats.ownDebts), muted: true),
                  const SizedBox(height: 8),
                  Text(l10n.agentProfitHint, style: TextStyle(fontSize: 12, color: colors.textMuted)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
