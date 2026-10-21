import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';
import 'package:bsmart/features/debts/domain/usecases/create_payment_usecase.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_like.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/payment_method_tiles.dart';

/// A single-debt payment sheet — records one payment against exactly one
/// `Debt` or `SaleDebt` via `POST /payments`. Returns `true` on success so
/// the caller knows to refresh.
class RecordPaymentSheet extends StatefulWidget {
  const RecordPaymentSheet({super.key, required this.debt});

  final DebtLike debt;

  static Future<bool?> show(BuildContext context, DebtLike debt) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => RecordPaymentSheet(debt: debt),
    );
  }

  @override
  State<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends State<RecordPaymentSheet> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.debt.balance.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = context.l10n.debtsEnterValidAmount);
      return;
    }
    if (amount > widget.debt.balance) {
      setState(
        () => _errorMessage = context.l10n.debtsAmountExceedsBalance(
          CurrencyFormatter.format(widget.debt.balance, widget.debt.currency),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await getIt<CreatePaymentUseCase>().call(
      CreatePaymentParams(
        debtId: widget.debt.kind == DebtKind.b2b ? widget.debt.id : null,
        saleDebtId: widget.debt.kind == DebtKind.saleDebt ? widget.debt.id : null,
        amount: amount,
        method: _method,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ),
    );
    if (!mounted) return;
    result.fold(
      (_) => Navigator.of(context).pop(true),
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final error = Theme.of(context).colorScheme.error;
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
                  l10n.debtsMakePayment,
                  style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DashTag(
                    label: l10n.commonBalanceWith(CurrencyFormatter.format(widget.debt.balance, widget.debt.currency)),
                    color: error,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: l10n.commonAmount,
                    prefixIcon: const Icon(Icons.payments_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                PaymentMethodTiles(selected: _method, onSheet: true, onSelected: (m) => setState(() => _method = m)),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.commonNoteOptional,
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: error, fontWeight: FontWeight.w700),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.commonConfirm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
