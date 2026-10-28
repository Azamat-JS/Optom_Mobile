import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/usecases/get_received_transfer_usecase.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One hand-over: per line what was given, what's left with the agent, what came back, the price
/// owed per unit and the selling range. The owner's cost appears only when the API sends it (the
/// owner's own view); a lead agent never gets it.
class AgentTransferDetailScreen extends StatefulWidget {
  const AgentTransferDetailScreen({required this.transferId, super.key});

  final String transferId;

  @override
  State<AgentTransferDetailScreen> createState() => _AgentTransferDetailScreenState();
}

class _AgentTransferDetailScreenState extends State<AgentTransferDetailScreen> {
  AgentTransferDetail? _detail;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetReceivedTransferUseCase>().call(widget.transferId);
    if (!mounted) return;
    setState(() => result.fold((d) => _detail = d, (failure) => _error = failure));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final detail = _detail;

    return DashPage(
      title: detail?.transfer.transferNumber ?? l10n.agentTransfersTitle,
      body: detail == null
          ? (_error != null
                ? DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$_error'))
                : const Center(child: CircularProgressIndicator()))
          : () {
              final t = detail.transfer;
              String money(double v) => CurrencyFormatter.format(v, t.currency);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  DashCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (t.debtStatus != null) DebtStatusBadge(status: t.debtStatus!),
                            const Spacer(),
                            Text(
                              agentDateFormat.format(t.createdAt.toLocal()),
                              style: TextStyle(fontSize: 12, color: colors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        BillRow(label: l10n.commonTotal, value: money(t.total), strong: true),
                        BillRow(label: l10n.agentDebtPaid, value: money(t.paidAmount), muted: true),
                        if (t.debtBalance != null) BillRow(label: l10n.agentDebtBalance, value: money(t.debtBalance!)),
                        if (detail.givenBy != null || detail.storeName != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (detail.givenBy != null) l10n.agentTransferGivenBy(detail.givenBy!.fullName),
                              ?detail.storeName,
                            ].join(' · '),
                            style: TextStyle(fontSize: 12, color: colors.textSecondary),
                          ),
                        ],
                        if (t.notes != null && t.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(t.notes!, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final line in detail.lines) ...[
                    DashCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(line.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 8),
                              Text(money(line.total), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.agentTransferLineQty(
                              agentQty(line.quantity, line.unit),
                              agentQty(line.remaining, line.unit),
                            ),
                            style: TextStyle(fontSize: 13, color: colors.textSecondary),
                          ),
                          if (line.returnedQuantity > 0)
                            Text(
                              l10n.agentTransferReturned(agentQty(line.returnedQuantity, line.unit)),
                              style: TextStyle(fontSize: 13, color: colors.textSecondary),
                            ),
                          Text(
                            [
                              l10n.agentTransferOwed(money(line.unitPrice)),
                              l10n.agentTransferRange(
                                l10n.agentPriceRange(money(line.minPrice), money(line.maxPrice)),
                              ),
                            ].join(' · '),
                            style: TextStyle(fontSize: 13, color: colors.textSecondary),
                          ),
                          if (line.costPrice != null)
                            Text(
                              l10n.agentLineCost(money(line.costPrice!)),
                              style: TextStyle(fontSize: 12, color: colors.textMuted),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }(),
    );
  }
}
