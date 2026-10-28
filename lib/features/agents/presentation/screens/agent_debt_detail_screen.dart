import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/usecases/get_agent_debt_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/get_team_debt_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/pay_agent_debt_usecase.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_dashboard_providers.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_debts_list_notifier.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_sales_list_notifier.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One customer debt: amounts, receiving a payment (full or part, never more than what's left —
/// the server re-checks it atomically), and the payment history.
class AgentDebtDetailScreen extends ConsumerStatefulWidget {
  const AgentDebtDetailScreen({required this.debtId, this.leadAgentId, super.key});

  final String debtId;

  /// Set when the business owner opens one of this lead agent's team debts: read-only.
  final String? leadAgentId;

  @override
  ConsumerState<AgentDebtDetailScreen> createState() => _AgentDebtDetailScreenState();
}

class _AgentDebtDetailScreenState extends ConsumerState<AgentDebtDetailScreen> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  AgentDebtDetail? _detail;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final leadAgentId = widget.leadAgentId;
    final result = leadAgentId == null
        ? await getIt<GetAgentDebtUseCase>().call(widget.debtId)
        : await getIt<GetTeamDebtUseCase>().call(leadAgentId, widget.debtId);
    if (!mounted) return;
    setState(() => result.fold((d) => _detail = d, (failure) => _error = failure));
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pay(AgentDebt debt) async {
    final l10n = context.l10n;
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return _snack(l10n.agentPayInvalid);
    if (amount > debt.balance + 0.0005) return _snack(l10n.agentPayTooMuch);

    setState(() => _busy = true);
    final result = await getIt<PayAgentDebtUseCase>().call(debt.id, amount: amount, notes: _notes.text.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold((detail) {
      HapticFeedback.mediumImpact();
      setState(() => _detail = detail);
      _amount.clear();
      _notes.clear();
      ref.read(agentDebtsListProvider.notifier).refresh();
      ref.read(agentSalesListProvider.notifier).refresh();
      ref.read(agentSummaryProvider.notifier).refresh();
      ref.invalidate(agentProfitProvider);
      _snack(l10n.agentPaid);
    }, (failure) => _snack(failure.message));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final detail = _detail;
    final debt = detail?.debt;

    return DashPage(
      title: debt?.customer.fullName ?? l10n.agentTabDebts,
      body: detail == null
          ? (_error != null
                ? DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$_error'))
                : const Center(child: CircularProgressIndicator()))
          : () {
              final d = detail.debt;
              String money(double v) => CurrencyFormatter.format(v, d.currency);
              return DashFormTheme(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    DashCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              DebtStatusBadge(status: d.status),
                              const Spacer(),
                              Text(
                                agentDateFormat.format(d.createdAt.toLocal()),
                                style: TextStyle(fontSize: 12, color: colors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            money(d.balance),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: d.isOpen ? Theme.of(context).colorScheme.error : colors.success,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [d.saleNumber, ?d.customer.phone].join(' · '),
                            style: TextStyle(fontSize: 12, color: colors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          BillRow(label: l10n.agentDebtOriginal, value: money(d.originalAmount)),
                          BillRow(label: l10n.agentDebtPaid, value: money(d.paidAmount), muted: true),
                          if (d.seller != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              l10n.agentSaleSeller(d.seller!.fullName),
                              style: TextStyle(fontSize: 12, color: colors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (d.isOpen && widget.leadAgentId == null) ...[
                      DashSectionTitle(l10n.agentPayTitle),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amount,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: l10n.commonAmount),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
                            onPressed: () => _amount.text = agentQty(d.balance),
                            child: Text(l10n.agentPayFull),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notes,
                        decoration: InputDecoration(labelText: l10n.commonNote),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                        onPressed: _busy ? null : () => _pay(d),
                        child: _busy
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                            : Text(l10n.agentPaySubmit),
                      ),
                    ] else if (!d.isOpen) ...[
                      const SizedBox(height: 12),
                      DashCard(child: Center(child: Text(l10n.agentDebtClosed))),
                    ],
                    DashSectionTitle(l10n.agentPaymentsHistory),
                    if (detail.payments.isEmpty)
                      Text(l10n.agentNoPayments, style: TextStyle(color: colors.textSecondary))
                    else
                      DashCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          children: [
                            for (final p in detail.payments)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(money(p.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                  [agentDateFormat.format(p.paidAt.toLocal()), ?p.by?.fullName, ?p.notes].join(' · '),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }(),
    );
  }
}
