import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/usecases/cancel_agent_return_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/get_agent_return_usecase.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_actions.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_request_status_tag.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One return: its lines (each from the transfer it came out of, at the price charged there), the
/// value, the cash refund once confirmed, and withdrawing it while pending. Pops `true` when the
/// return was withdrawn, so the caller refreshes stock and the account.
class AgentReturnDetailScreen extends StatefulWidget {
  const AgentReturnDetailScreen({required this.returnId, super.key});

  final String returnId;

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final detail = _detail;
    final ret = detail?.ret;

    return DashPage(
      title: ret?.returnNumber ?? l10n.agentTabReturns,
      bottomBar: ret?.status == AgentRequestStatus.pending
          ? DashBottomButton(
              label: l10n.agentCancelRequest,
              icon: Icons.undo_rounded,
              busy: _busy,
              onPressed: _cancel,
            )
          : null,
      body: detail == null
          ? (_error != null
                ? DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$_error'))
                : const Center(child: CircularProgressIndicator()))
          : () {
              final r = detail.ret;
              String money(double v) => CurrencyFormatter.format(v, r.currency);
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
