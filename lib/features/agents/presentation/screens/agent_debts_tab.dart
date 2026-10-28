import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_debts_list_notifier.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_debt_detail_screen.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Qarzdorlar": debts from agent sales — when and how much, and what's left. A lead agent sees
/// its whole team's, a staff agent the ones it made.
class AgentDebtsTab extends ConsumerStatefulWidget {
  const AgentDebtsTab({super.key});

  @override
  ConsumerState<AgentDebtsTab> createState() => _AgentDebtsTabState();
}

class _AgentDebtsTabState extends ConsumerState<AgentDebtsTab> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        ref.read(agentDebtsListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => ref.read(agentDebtsListProvider.notifier).search(text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLead = ref.watch(sessionNotifierProvider).valueOrNull?.session?.role == UserRole.leadAgent;
    final listAsync = ref.watch(agentDebtsListProvider);
    final openOnly = listAsync.valueOrNull?.openOnly ?? true;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: DashSearchField(controller: _search, hint: l10n.commonSearchHint, onChanged: _onSearch),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: PillToggle<bool>(
            values: const [true, false],
            selected: openOnly,
            expand: true,
            label: (open) => open ? l10n.agentDebtsOpen : l10n.agentDebtsAll,
            onChanged: (open) => ref.read(agentDebtsListProvider.notifier).setOpenOnly(open),
          ),
        ),
        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
            data: (state) => RefreshIndicator(
              color: AppColors.onBrand,
              backgroundColor: AppColors.brandYellow,
              onRefresh: () => ref.read(agentDebtsListProvider.notifier).refresh(),
              child: ListView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  if (state.openOnly) _TotalCard(state: state),
                  if (state.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(child: Text(l10n.agentDebtsEmpty)),
                    ),
                  for (final debt in state.items) ...[
                    const SizedBox(height: 10),
                    AgentDebtCard(debt: debt, showSeller: isLead),
                  ],
                  if (state.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.state});

  final AgentDebtsListState state;

  @override
  Widget build(BuildContext context) {
    final total = state.totalBalance;
    final parts = [
      CurrencyFormatter.format(total.uzs, Currency.uzs),
      if (total.usd > 0) CurrencyFormatter.format(total.usd, Currency.usd),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.agentDebtsTotal,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            parts.join(' · '),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// One customer-debt row. [leadAgentId] set = the owner's read-only view of that lead agent's team.
class AgentDebtCard extends ConsumerWidget {
  const AgentDebtCard({required this.debt, required this.showSeller, this.leadAgentId, super.key});

  final AgentDebt debt;
  final bool showSeller;
  final String? leadAgentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    String money(double v) => CurrencyFormatter.format(v, debt.currency);
    return DashCard(
      padding: const EdgeInsets.all(14),
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AgentDebtDetailScreen(debtId: debt.id, leadAgentId: leadAgentId),
          ),
        );
      },
      child: Row(
        children: [
          DashAvatar(name: debt.customer.firstName, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(debt.customer.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  [agentDateFormat.format(debt.createdAt.toLocal()), ?debt.customer.phone].join(' · '),
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                Text(
                  '${l10n.agentDebtOriginal}: ${money(debt.originalAmount)}',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                if (showSeller && debt.seller != null)
                  Text(
                    l10n.agentSaleSeller(debt.seller!.fullName),
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(debt.balance),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: debt.isOpen ? Theme.of(context).colorScheme.error : colors.success,
                ),
              ),
              const SizedBox(height: 4),
              DebtStatusBadge(status: debt.status),
            ],
          ),
        ],
      ),
    );
  }
}
