import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/usecases/cancel_agent_return_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/confirm_agent_return_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/get_agent_return_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/reject_agent_return_usecase.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_money.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_actions.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_status_tag.dart';
import 'package:bsmart/features/agents/presentation/widgets/owner_decision_dialogs.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One return: its lines (each from the transfer it came out of, at the price charged there), the
/// value and the cash refund once confirmed. While pending, the lead agent can withdraw it, and the
/// owner ([ownerDebt] set) confirms or rejects it. Pops `true` after any of these, so the caller
/// refreshes.
class AgentReturnDetailScreen extends StatefulWidget {
  const AgentReturnDetailScreen({required this.returnId, this.ownerDebt, super.key});

  final String returnId;

  /// The owner's view: the lead agent's open debt, to preview how a confirmation splits into
  /// "taken off the debt" and "refunded in cash" (the server makes the same split).
  final MoneyByCurrency? ownerDebt;

  @override
  State<AgentReturnDetailScreen> createState() => _AgentReturnDetailScreenState();
}

class _AgentReturnDetailScreenState extends State<AgentReturnDetailScreen> {
  AgentReturnDetail? _detail;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetAgentReturnUseCase>().call(widget.returnId);
    if (!mounted) return;
    setState(() => result.fold((d) => _detail = d, (failure) => _error = failure));
  }

  Future<void> _cancel() async {
    if (!await confirmAgentRequestCancel(context)) return;
    setState(() => _busy = true);
    final result = await getIt<CancelAgentReturnUseCase>().call(widget.returnId);
    if (!mounted) return;
    result.fold(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.agentRequestCancelled)));
        Navigator.of(context).pop(true);
      },
      (failure) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  /// (taken off the debt, refunded in cash) if the owner confirms now.
  (double, double)? _split(AgentReturn r) {
    final debt = widget.ownerDebt;
    if (debt == null) return null;
    final owed = agentAmountIn(debt, r.currency);
    final refund = (r.value - owed).clamp(0, double.infinity).toDouble();
    return (r.value - refund, refund);
  }

  Future<void> _decide(AgentReturn r, {required bool confirm}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    Result<void> result;
    if (confirm) {
      final split = _split(r);
      String money(double v) => CurrencyFormatter.format(v, r.currency);
      final ok = await askOwnerConfirm(
        context,
        title: l10n.ownerConfirmReturnTitle,
        text: l10n.ownerConfirmReturnText,
        lines: [
          if (split != null) l10n.ownerDebtReduceLine(money(split.$1)),
          if (split != null && split.$2 > 0) l10n.ownerRefundLine(money(split.$2)),
        ],
      );
      if (!ok || !mounted) return;
      setState(() => _busy = true);
      result = await getIt<ConfirmAgentReturnUseCase>().call(r.id);
    } else {
      final reason = await askRejectReason(context);
      if (reason == null || !mounted) return;
      setState(() => _busy = true);
      result = await getIt<RejectAgentReturnUseCase>().call(r.id, reason: reason);
    }
    if (!mounted) return;
    result.fold(
      (_) {
        messenger.showSnackBar(SnackBar(content: Text(confirm ? l10n.ownerConfirmed : l10n.ownerRejected)));
        Navigator.of(context).pop(true);
      },
      (failure) {
        setState(() => _busy = false);
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final detail = _detail;
    final ret = detail?.ret;
    final pending = ret?.status == AgentRequestStatus.pending;
    final ownerView = widget.ownerDebt != null;

    return DashPage(
      title: ret?.returnNumber ?? l10n.agentTabReturns,
      bottomBar: !pending
          ? null
          : ownerView
          ? OwnerDecisionBar(
              busy: _busy,
              onReject: () => _decide(ret!, confirm: false),
              onConfirm: () => _decide(ret!, confirm: true),
            )
          : DashBottomButton(label: l10n.agentCancelRequest, icon: Icons.undo_rounded, busy: _busy, onPressed: _cancel),
      body: detail == null
          ? (_error != null
                ? DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$_error'))
                : const Center(child: CircularProgressIndicator()))
          : () {
              final r = detail.ret;
              String money(double v) => CurrencyFormatter.format(v, r.currency);
              final split = r.status == AgentRequestStatus.pending ? _split(r) : null;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  DashCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AgentRequestStatusTag(status: r.status),
                            const Spacer(),
                            Text(
                              agentDateFormat.format(r.createdAt.toLocal()),
                              style: TextStyle(fontSize: 12, color: colors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        BillRow(label: l10n.agentReturnValue, value: money(r.value), strong: true),
                        if (r.refundAmount > 0) BillRow(label: l10n.agentRefund, value: money(r.refundAmount)),
                        if (split != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            l10n.ownerDebtReduceLine(money(split.$1)),
                            style: TextStyle(color: colors.textSecondary),
                          ),
                          if (split.$2 > 0)
                            Text(
                              l10n.ownerRefundLine(money(split.$2)),
                              style: TextStyle(color: colors.accentText, fontWeight: FontWeight.w700),
                            ),
                        ],
                        if (r.notes != null && r.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(r.notes!, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                        ],
                        if (r.rejectReason != null && r.rejectReason!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            l10n.agentRejectReason(r.rejectReason!),
                            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  DashCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      children: [
                        for (final line in detail.lines)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(line.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              [
                                '${agentQty(line.quantity, line.unit)} × ${money(line.unitPrice)}',
                                if (line.transferNumber.isNotEmpty) l10n.agentReturnFromTransfer(line.transferNumber),
                              ].join(' · '),
                            ),
                            trailing: Text(
                              money(line.quantity * line.unitPrice),
                              style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }(),
    );
  }
}
