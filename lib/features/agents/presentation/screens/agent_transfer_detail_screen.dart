import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/usecases/get_received_transfer_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/update_agent_transfer_salary_usecase.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One hand-over: per line what was given, what's left with the agent, what came back, the price
/// owed per unit and the selling range. The owner's cost appears only when the API sends it (the
/// owner's own view); a lead agent never gets it. Both see the lead agent's salary on it.
class AgentTransferDetailScreen extends StatefulWidget {
  const AgentTransferDetailScreen({required this.transferId, this.onSalaryChanged, super.key});

  final String transferId;

  /// Owner only: lets it correct the salary %, and is called after a save (the server refuses
  /// everyone else anyway).
  final VoidCallback? onSalaryChanged;

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

  Future<void> _editSalary(AgentTransfer t) async {
    final updated = await showDialog<AgentTransferDetail>(
      context: context,
      builder: (_) => _SalaryPercentDialog(transfer: t),
    );
    if (updated == null || !mounted) return;
    setState(() => _detail = updated);
    widget.onSalaryChanged?.call();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.agentSalaryPercentSaved)));
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
                  _SalaryCard(
                    transfer: t,
                    onEdit: widget.onSalaryChanged == null ? null : () => _editSalary(t),
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
                              l10n.agentTransferRange(agentPriceText(l10n, money(line.maxPrice), line.discountPercent)),
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

/// The lead agent's salary on this transfer: its % of what the team has sold from these units.
class _SalaryCard extends StatelessWidget {
  const _SalaryCard({required this.transfer, this.onEdit});

  final AgentTransfer transfer;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final t = transfer;
    String money(double v) => CurrencyFormatter.format(v, t.currency);
    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.agentSalaryTitle} · ${agentQty(t.salaryPercent)}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(l10n.agentSalaryEdit),
                ),
            ],
          ),
          const SizedBox(height: 6),
          BillRow(label: l10n.agentSalarySold, value: money(t.salarySoldRevenue), muted: true),
          BillRow(label: l10n.agentSalaryEarned, value: money(t.salaryEarned), strong: true),
          if (t.salaryPercent <= 0) ...[
            const SizedBox(height: 4),
            Text(l10n.agentSalaryNone, style: TextStyle(fontSize: 12, color: colors.textMuted)),
          ],
        ],
      ),
    );
  }
}

/// Owner: corrects the transfer's salary %. Pops the updated transfer once saved.
class _SalaryPercentDialog extends StatefulWidget {
  const _SalaryPercentDialog({required this.transfer});

  final AgentTransfer transfer;

  @override
  State<_SalaryPercentDialog> createState() => _SalaryPercentDialogState();
}

class _SalaryPercentDialogState extends State<_SalaryPercentDialog> {
  late final _percent = TextEditingController(
    text: widget.transfer.salaryPercent > 0 ? agentQty(widget.transfer.salaryPercent) : '',
  );
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _percent.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _percent.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final text = _percent.text.trim().replaceAll(',', '.');
    final percent = text.isEmpty ? 0.0 : double.tryParse(text);
    if (percent == null || !agentDiscountValid(percent)) return setState(() => _error = l10n.agentSalaryPercentInvalid);
    setState(() => _busy = true);
    final result = await getIt<UpdateAgentTransferSalaryUseCase>().call(widget.transfer.id, percent);
    if (!mounted) return;
    result.fold(
      (detail) => Navigator.of(context).pop(detail),
      (failure) => setState(() {
        _busy = false;
        _error = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return AlertDialog(
      title: Text(l10n.agentSalaryEdit),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _percent,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.agentSalaryPercent, hintText: '0'),
          ),
          const SizedBox(height: 10),
          Text(l10n.agentSalaryEditHint, style: TextStyle(fontSize: 12, color: colors.textMuted)),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.commonSave)),
      ],
    );
  }
}
