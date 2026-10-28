import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/usecases/cancel_payment_request_usecase.dart';
import 'package:bsmart/features/agents/presentation/providers/lead_agent_providers.dart';
import 'package:bsmart/features/agents/presentation/screens/agent_return_detail_screen.dart';
import 'package:bsmart/features/agents/presentation/screens/return_goods_screen.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_money.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_actions.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_status_tag.dart';
import 'package:bsmart/features/agents/presentation/widgets/send_payment_sheet.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

enum _RequestTab { payments, returns }

/// "Hisob-kitob" (lead agent only): what it owes the owner, what's waiting for the owner, and its
/// payment / return requests — with sending a payment, returning goods, and withdrawing a pending
/// request. Nothing moves the debt until the owner confirms.
class LeadAccountScreen extends ConsumerStatefulWidget {
  const LeadAccountScreen({super.key});

  @override
  ConsumerState<LeadAccountScreen> createState() => _LeadAccountScreenState();
}

class _LeadAccountScreenState extends ConsumerState<LeadAccountScreen> {
  _RequestTab _tab = _RequestTab.payments;

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _sendPayment(LeadAgentAccount account) async {
    final l10n = context.l10n;
    final available = account.available;
    if (available.uzs <= 0 && available.usd <= 0) return _snack(l10n.agentNothingOwed);
    final sent = await SendPaymentSheet.show(context, account);
    if (sent != true || !mounted) return;
    refreshAfterAgentRequest(ref);
    setState(() => _tab = _RequestTab.payments);
    _snack(l10n.agentPaymentSent);
  }

  Future<void> _returnGoods() async {
    final sent = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const ReturnGoodsScreen()));
    if (sent != true || !mounted) return;
    refreshAfterAgentRequest(ref, stockChanged: true);
    setState(() => _tab = _RequestTab.returns);
    _snack(context.l10n.agentReturnSent);
  }

  Future<void> _cancelPayment(AgentPaymentRequest request) async {
    if (!await confirmAgentRequestCancel(context)) return;
    final result = await getIt<CancelPaymentRequestUseCase>().call(request.id);
    if (!mounted) return;
    result.fold(
      (_) {
        refreshAfterAgentRequest(ref);
        _snack(context.l10n.agentRequestCancelled);
      },
      (failure) => _snack(failure.message),
    );
  }

  Future<void> _openReturn(AgentReturn ret) async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => AgentReturnDetailScreen(returnId: ret.id)));
    if (changed == true && mounted) refreshAfterAgentRequest(ref, stockChanged: true);
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(leadAccountProvider.notifier).refresh(),
      ref.read(leadPaymentRequestsProvider.notifier).refresh(),
      ref.read(leadReturnsProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final accountAsync = ref.watch(leadAccountProvider);
    final account = accountAsync.valueOrNull;

    return DashPage(
      title: l10n.agentAccountTitle,
      body: RefreshIndicator(
        color: AppColors.onBrand,
        backgroundColor: AppColors.brandYellow,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            if (account == null)
              accountAsync.hasError
                  ? DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('${accountAsync.error}'))
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
            else ...[
              if (account.ownerName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    l10n.agentAccountWith(account.ownerName),
                    style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              _AccountCard(account: account),
              const SizedBox(height: 12),
              // Stacked: side by side, the longer label is cut off on a phone.
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: () => _sendPayment(account),
                icon: const Icon(Icons.payments_rounded),
                label: Text(l10n.agentSendPayment),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: _returnGoods,
                icon: const Icon(Icons.assignment_return_rounded),
                label: Text(l10n.agentReturnGoods),
              ),
            ],
            const SizedBox(height: 18),
            PillToggle<_RequestTab>(
              values: _RequestTab.values,
              selected: _tab,
              expand: true,
              label: (t) => switch (t) {
                _RequestTab.payments => l10n.agentTabPayments,
                _RequestTab.returns => l10n.agentTabReturns,
              },
              onChanged: (t) => setState(() => _tab = t),
            ),
            const SizedBox(height: 12),
            if (_tab == _RequestTab.payments)
              _PaymentsList(onCancel: _cancelPayment)
            else
              _ReturnsList(onOpen: _openReturn),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final LeadAgentAccount account;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final owes = account.debt.uzs > 0 || account.debt.usd > 0;
    final hasPending = account.pendingPayments.uzs > 0 || account.pendingPayments.usd > 0;
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.agentMyDebt, style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            owes ? agentMoneyBoth(account.debt) : l10n.agentNothingOwed,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: owes ? Theme.of(context).colorScheme.error : colors.success,
            ),
          ),
          const SizedBox(height: 10),
          BillRow(
            label: l10n.agentPendingPayments,
            value: hasPending ? agentMoneyBoth(account.pendingPayments) : '—',
            muted: !hasPending,
          ),
          BillRow(
            label: l10n.agentPendingReturns,
            value: account.pendingReturns > 0 ? '${account.pendingReturns}' : '—',
            muted: account.pendingReturns == 0,
          ),
        ],
      ),
    );
  }
}

class _PaymentsList extends ConsumerWidget {
  const _PaymentsList({required this.onCancel});

  final ValueChanged<AgentPaymentRequest> onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return ref
        .watch(leadPaymentRequestsProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
          data: (items) => items.isEmpty
              ? DashEmptyState(icon: Icons.payments_outlined, text: l10n.agentPaymentsEmpty)
              : Column(
                  children: [
                    for (final (i, p) in items.indexed) ...[
                      if (i > 0) const SizedBox(height: 10),
                      DashCard(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(p.amount, p.currency),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    [agentDateFormat.format(p.createdAt.toLocal()), ?p.notes].join(' · '),
                                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                  ),
                                  if (p.rejectReason != null && p.rejectReason!.isNotEmpty)
                                    Text(
                                      l10n.agentRejectReason(p.rejectReason!),
                                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AgentRequestStatusTag(status: p.status),
                                if (p.status == AgentRequestStatus.pending)
                                  TextButton(onPressed: () => onCancel(p), child: Text(l10n.agentCancelRequest)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        );
  }
}

class _ReturnsList extends ConsumerWidget {
  const _ReturnsList({required this.onOpen});

  final ValueChanged<AgentReturn> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return ref
        .watch(leadReturnsProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$error')),
          data: (items) => items.isEmpty
              ? DashEmptyState(icon: Icons.assignment_return_outlined, text: l10n.agentReturnsEmpty)
              : Column(
                  children: [
                    for (final (i, r) in items.indexed) ...[
                      if (i > 0) const SizedBox(height: 10),
                      DashCard(
                        onTap: () => onOpen(r),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.returnNumber, style: const TextStyle(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(
                                    [
                                      agentDateFormat.format(r.createdAt.toLocal()),
                                      l10n.agentCartCount(r.itemCount),
                                    ].join(' · '),
                                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                  ),
                                  if (r.refundAmount > 0)
                                    Text(
                                      '${l10n.agentRefund}: ${CurrencyFormatter.format(r.refundAmount, r.currency)}',
                                      style: TextStyle(fontSize: 12, color: colors.success, fontWeight: FontWeight.w700),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(r.value, r.currency),
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                AgentRequestStatusTag(status: r.status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        );
  }
}
