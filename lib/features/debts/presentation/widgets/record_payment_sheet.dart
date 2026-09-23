import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';
import 'package:bsmart/features/debts/domain/usecases/create_payment_usecase.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_like.dart';

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
      setState(() => _errorMessage = "To'g'ri summa kiriting");
      return;
    }
    if (amount > widget.debt.balance) {
      setState(() => _errorMessage = 'Summa qoldiqdan (${CurrencyFormatter.format(widget.debt.balance, widget.debt.currency)}) oshmasligi kerak');
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("To'lov qilish", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Qoldiq: ${CurrencyFormatter.format(widget.debt.balance, widget.debt.currency)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Summa', border: OutlineInputBorder(), isDense: true),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _method,
                decoration: const InputDecoration(labelText: "To'lov usuli", border: OutlineInputBorder(), isDense: true),
                items: [
                  for (final method in PaymentMethod.immediateMethods)
                    DropdownMenuItem(value: method, child: Text(method.label)),
                ],
                onChanged: (value) => setState(() => _method = value ?? _method),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Izoh (ixtiyoriy)', border: OutlineInputBorder(), isDense: true),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Tasdiqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
