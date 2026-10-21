import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/debts/presentation/providers/debts_list_notifier.dart';
import 'package:bsmart/features/debts/presentation/providers/sale_debts_list_notifier.dart';
import 'package:bsmart/features/debts/presentation/screens/debt_group_detail_screen.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_like.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The Debts hub — two tabs mirroring the two backend debt models: "B2B"
/// (`Debt`, wholesaler↔retailer) and "Mijozlar" (`SaleDebt`, B2C, always
/// created by a POS DEBT sale). Each tab groups the flat list client-side by
/// person+currency (the FIFO pay-down's natural unit) rather than showing
/// raw individual debt rows.
///
/// Phase 9 U4c3: the two tabs are a pill toggle; a dark summary card shows the
/// total per currency and the number of people; each person is a card.
class DebtsListScreen extends ConsumerStatefulWidget {
  const DebtsListScreen({super.key});

  @override
  ConsumerState<DebtsListScreen> createState() => _DebtsListScreenState();
}

class _DebtsListScreenState extends ConsumerState<DebtsListScreen> {
  /// 0 = B2B (`Debt`), 1 = customers (`SaleDebt`).
  int _tab = 0;
  String? _b2bRole;

  bool get _isRetailer {
    final role = ref.read(sessionNotifierProvider).valueOrNull?.session?.role;
    return role == UserRole.retailer || role == UserRole.retailerAdmin;
  }

  void _openGroup(DebtGroup group) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DebtGroupDetailScreen(group: group)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DashPage(
      title: l10n.debtsTitle,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PillToggle<int>(
            values: const [0, 1],
            selected: _tab,
            expand: true,
            label: (t) => t == 0 ? 'B2B' : l10n.debtsTabCustomers,
            onChanged: (t) => setState(() => _tab = t),
          ),
          if (_tab == 0 && _isRetailer) ...[
            const SizedBox(height: 10),
            DashChoiceChips<String>(
              values: const ['', 'debtor'],
              selected: _b2bRole ?? '',
              label: (r) => r.isEmpty ? l10n.debtsTabOwedToMe : l10n.debtsTabMine,
              onSelected: (r) {
                final role = r.isEmpty ? null : r;
                setState(() => _b2bRole = role);
                ref.read(debtsListProvider.notifier).setRole(role);
              },
            ),
          ],
        ],
      ),
      // Both stay built so switching keeps each list's scroll position.
      body: IndexedStack(index: _tab, children: [_buildB2bTab(), _buildSaleDebtsTab()]),
    );
  }

  Widget _error(Object error, VoidCallback retry) => DashEmptyState(
    icon: Icons.cloud_off_rounded,
    text: context.l10n.commonErrorWith('$error'),
    action: TextButton(onPressed: retry, child: Text(context.l10n.commonRetry)),
  );

  Widget _buildB2bTab() {
    final debtsAsync = ref.watch(debtsListProvider);
    return debtsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _error(error, () => ref.invalidate(debtsListProvider)),
      data: (debts) {
        final currentUserId = ref.read(sessionNotifierProvider).valueOrNull?.session?.userId ?? '';
        final groups = groupDebts(debts, currentUserId: currentUserId);
        return RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(debtsListProvider.notifier).refresh(),
          child: groups.isEmpty
              ? DashEmptyState(icon: Icons.request_quote_rounded, text: context.l10n.debtsNotFound)
              : _buildGroupList(groups),
        );
      },
    );
  }

  Widget _buildSaleDebtsTab() {
    final saleDebtsAsync = ref.watch(saleDebtsListProvider);
    return saleDebtsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _error(error, () => ref.invalidate(saleDebtsListProvider)),
      data: (saleDebts) {
        final groups = groupSaleDebts(saleDebts);
        return RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(saleDebtsListProvider.notifier).refresh(),
          child: groups.isEmpty
              ? DashEmptyState(icon: Icons.groups_rounded, text: context.l10n.debtsCustomerNotFound)
              : _buildGroupList(groups),
        );
      },
    );
  }

  Widget _buildGroupList(List<DebtGroup> groups) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    // Never summed across currencies: one total per currency present.
    final totals = <Currency, double>{};
    for (final g in groups) {
      totals[g.currency] = (totals[g.currency] ?? 0) + g.totalBalance;
    }
    final debtorView = groups.first.viewerIsDebtor;

    return ListView(
      // A short list (e.g. one group) doesn't fill the viewport, and Android's
      // default ClampingScrollPhysics then never overscrolls — RefreshIndicator
      // needs that overscroll to trigger, so pull-to-refresh silently does
      // nothing without this. Confirmed live: pull-to-refresh had no effect
      // with a single debt group until this was added.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.ink, Color(0xFF2A1210)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                debtorView ? l10n.debtsTabMine : l10n.debtsSummaryTotal,
                style: TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              for (final entry in totals.entries)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(entry.value, entry.key),
                    style: const TextStyle(
                      fontFamily: BrandTheme.fontFamily,
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                l10n.debtsPeopleCount(groups.map((g) => g.personName).toSet().length),
                style: const TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  color: AppColors.brandYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final (i, group) in groups.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          DashListCard(
            leading: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (group.totalBalance > 0 ? error : AppColors.success).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                group.personName.characters.firstOrNull?.toUpperCase() ?? '?',
                style: TextStyle(
                  color: group.totalBalance > 0 ? error : AppColors.success,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: group.personName,
            subtitle: [
              l10n.debtsActiveCount(group.activeCount),
              if (group.personPhone != null) group.personPhone!,
            ].join(' · '),
            trailing: Text(
              CurrencyFormatter.format(group.totalBalance, group.currency),
              style: TextStyle(
                color: group.totalBalance > 0 ? error : colors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            onTap: () => _openGroup(group),
          ).animate().fadeIn(delay: (25 * (i % 12)).ms, duration: AppMotion.standard),
        ],
      ],
    );
  }
}
