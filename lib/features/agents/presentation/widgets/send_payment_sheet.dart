import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/usecases/send_payment_request_usecase.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_money.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "To'lov yuborish": the lead agent tells the owner how much it paid. Capped at open debt minus
/// requests already pending (the server re-checks); the currency choice appears only when it owes
/// dollars too. Returns `true` once sent.
class SendPaymentSheet extends StatefulWidget {
  const SendPaymentSheet({required this.account, super.key});

  final LeadAgentAccount account;

  static Future<bool?> show(BuildContext context, LeadAgentAccount account) => showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SendPaymentSheet(account: account),
  );

  @override
  State<SendPaymentSheet> createState() => _SendPaymentSheetState();
}

class _SendPaymentSheetState extends State<SendPaymentSheet> {
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  late final List<Currency> _currencies = [
    for (final c in Currency.values)
      if (agentAmountIn(widget.account.available, c) > 0) c,
  ];
  late Currency _currency = _currencies.isEmpty ? Currency.uzs : _currencies.first;
  bool _busy = false;
  String? _error;

  double get _available => agentAmountIn(widget.account.available, _currency);

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    if (amount == null || amount <= 0) return setState(() => _error = l10n.agentPayInvalid);
    if (amount > _available + 0.0005) return setState(() => _error = l10n.agentPayTooMuch);

    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await getIt<SendPaymentRequestUseCase>().call(
      amount: amount,
      currency: _currency,
      notes: _notes.text.trim(),
    );
    if (!mounted) return;
    result.fold(
      (_) => Navigator.of(context).pop(true),
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
    return DashFormTheme(
      onSheet: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.agentSendPayment,
                  style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(l10n.agentSendPaymentHint, style: TextStyle(color: colors.textSecondary)),
                if (_currencies.length > 1) ...[
                  const SizedBox(height: 14),
                  PillToggle<Currency>(
                    values: _currencies,
                    selected: _currency,
                    expand: true,
                    label: (c) => c.toWire(),
                    onChanged: (c) => setState(() {
                      _currency = c;
                      _amount.clear();
                    }),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DashTag(
                    label: l10n.agentAvailableToSend(CurrencyFormatter.format(_available, _currency)),
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          labelText: l10n.commonAmount,
                          prefixIcon: const Icon(Icons.payments_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
                      onPressed: () => _amount.text = agentQty(_available),
                      child: Text(l10n.agentPayFull),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  decoration: InputDecoration(
                    labelText: l10n.commonNoteOptional,
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : Text(l10n.agentSendPayment),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
