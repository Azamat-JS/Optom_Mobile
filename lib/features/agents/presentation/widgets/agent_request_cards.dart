import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_status_tag.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

// Rows shared by the lead agent's account and the owner's lead-agent page.

/// A payment request: amount, date, note, the owner's reject reason, status, and [actions]
/// (withdraw for the lead agent, confirm/reject for the owner) under the status.
class AgentPaymentRequestCard extends StatelessWidget {
  const AgentPaymentRequestCard({required this.request, this.actions = const [], super.key});

  final AgentPaymentRequest request;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final p = request;
    return DashCard(
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
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AgentRequestStatusTag(status: p.status),
              ),
              ...actions,
            ],
          ),
        ],
      ),
    );
  }
}

/// A return: number, date, item count, value, status and the cash refund once confirmed.
class AgentReturnCard extends StatelessWidget {
  const AgentReturnCard({required this.ret, required this.onTap, super.key});

  final AgentReturn ret;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final r = ret;
    return DashCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.returnNumber, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  [agentDateFormat.format(r.createdAt.toLocal()), l10n.agentCartCount(r.itemCount)].join(' · '),
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
              Text(CurrencyFormatter.format(r.value, r.currency), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              AgentRequestStatusTag(status: r.status),
            ],
          ),
        ],
      ),
    );
  }
}

/// A transfer: number, date, item count, paid on hand-over and still owed, total and debt status.
class AgentTransferCard extends StatelessWidget {
  const AgentTransferCard({required this.transfer, required this.onTap, super.key});

  final AgentTransfer transfer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final t = transfer;
    String money(double v) => CurrencyFormatter.format(v, t.currency);
    return DashCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.transferNumber, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  [agentDateFormat.format(t.createdAt.toLocal()), l10n.agentCartCount(t.itemCount)].join(' · '),
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
                if (t.paidAmount > 0)
                  Text(
                    l10n.agentTransferPaid(money(t.paidAmount)),
                    style: TextStyle(fontSize: 12, color: colors.success, fontWeight: FontWeight.w700),
                  ),
                if ((t.debtBalance ?? 0) > 0)
                  Text(
                    l10n.agentTransferDebt(money(t.debtBalance!)),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money(t.total), style: const TextStyle(fontWeight: FontWeight.w800)),
              if (t.debtStatus != null) ...[const SizedBox(height: 4), DebtStatusBadge(status: t.debtStatus!)],
            ],
          ),
        ],
      ),
    );
  }
}
