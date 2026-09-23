import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';
import 'package:bsmart/features/debts/domain/usecases/close_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/get_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/get_sale_debt_usecase.dart';
import 'package:bsmart/features/debts/domain/usecases/pay_down_usecase.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_like.dart';
import 'package:bsmart/features/debts/presentation/widgets/debt_status_badge.dart';
import 'package:bsmart/features/debts/presentation/widgets/record_payment_sheet.dart';

/// One person's (or notes-identified debtor's) aggregated debts in one
/// currency. Two ways to pay: a lump sum via FIFO (`POST /payments/pay-down`,
/// oldest debt first — this screen mirrors the backend's exact allocation
/// order client-side so the "preview" shown before confirming is always
/// correct, not just illustrative) or a payment against one specific debt
/// (`RecordPaymentSheet`, `POST /payments`).
class DebtGroupDetailScreen extends StatefulWidget {
  const DebtGroupDetailScreen({super.key, required this.group});

  final DebtGroup group;

  @override
  State<DebtGroupDetailScreen> createState() => _DebtGroupDetailScreenState();
}

class _DebtGroupDetailScreenState extends State<DebtGroupDetailScreen> {
  late DebtGroup _group = widget.group;
  final _payDownAmountController = TextEditingController();
  PaymentMethod _payDownMethod = PaymentMethod.cash;
  bool _isPayingDown = false;
  String? _payDownError;

  @override
  void dispose() {
    _payDownAmountController.dispose();
    super.dispose();
  }

  List<DebtLike> get _activeItemsOldestFirst {
    final active = _group.items.where((i) => !i.isSettled).toList();
    active.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return active;
  }

  /// Mirrors `PaymentService.payDown()`'s allocation loop exactly (oldest
  /// debt first, applied up to each row's own balance) — see
  /// `payment.service.ts`. Purely a client-side preview; the server
  /// re-runs this same logic authoritatively on submit.
  List<(DebtLike, double)> _previewAllocation(double amount) {
    var remaining = amount;
    final allocations = <(DebtLike, double)>[];
    for (final item in _activeItemsOldestFirst) {
      if (remaining <= 0) break;
      final applied = remaining < item.balance ? remaining : item.balance;
      if (applied <= 0) continue;
      allocations.add((item, applied));
      remaining -= applied;
    }
    return allocations;
  }

  Future<void> _refreshGroup() async {
    final updatedItems = <DebtLike>[];
    for (final item in _group.items) {
      if (item.kind == DebtKind.b2b) {
        final result = await getIt<GetDebtUseCase>().call(item.id);
        result.fold((debt) => updatedItems.add(DebtLike.fromDebt(debt)), (_) => updatedItems.add(item));
      } else {
        final result = await getIt<GetSaleDebtUseCase>().call(item.id);
        result.fold((debt) => updatedItems.add(DebtLike.fromSaleDebt(debt)), (_) => updatedItems.add(item));
      }
    }
    if (!mounted) return;
    setState(() {
      _group = DebtGroup(
        kind: _group.kind,
        personId: _group.personId,
        personNotesKey: _group.personNotesKey,
        personName: _group.personName,
        personPhone: _group.personPhone,
        currency: _group.currency,
        items: updatedItems,
      );
    });
  }

  Future<void> _submitPayDown(double amount) async {
    setState(() {
      _isPayingDown = true;
      _payDownError = null;
    });

    final result = await getIt<PayDownUseCase>().call(
      PayDownParams(
        debtorId: _group.kind == DebtKind.b2b ? _group.personId : null,
        debtorNotes: _group.kind == DebtKind.b2b ? _group.personNotesKey : null,
        customerId: _group.kind == DebtKind.saleDebt ? _group.personId : null,
        amount: amount,
        currency: _group.currency,
        method: _payDownMethod,
      ),
    );
    if (!mounted) return;
    result.fold(
      (payDownResult) async {
        _payDownAmountController.clear();
        setState(() => _isPayingDown = false);
        await _refreshGroup();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${payDownResult.paymentCount} ta qarzga toʻlov qoʻllanildi')),
        );
      },
      (failure) => setState(() {
        _isPayingDown = false;
        _payDownError = failure.message;
      }),
    );
  }

  Future<void> _recordSinglePayment(DebtLike item) async {
    final saved = await RecordPaymentSheet.show(context, item);
    if (saved == true) _refreshGroup();
  }

  Future<void> _closeDebt(DebtLike item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Qarzni yopish'),
        content: Text(
          'Qolgan ${CurrencyFormatter.format(item.balance, item.currency)} toʻliq toʻlangan deb belgilansinmi?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yopish')),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await getIt<CloseDebtUseCase>().call(item.id, const CloseDebtParams());
    if (!mounted) return;
    result.fold(
      (_) => _refreshGroup(),
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_payDownAmountController.text.trim());
    final preview = (amount != null && amount > 0) ? _previewAllocation(amount) : const <(DebtLike, double)>[];
    final totalActiveBalance = _activeItemsOldestFirst.fold<double>(0, (sum, i) => sum + i.balance);

    return Scaffold(
      appBar: AppBar(title: Text(_group.personName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_group.personPhone != null) Text(_group.personPhone!),
                  const SizedBox(height: 4),
                  Text(
                    'Jami qoldiq: ${CurrencyFormatter.format(totalActiveBalance, _group.currency)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          if (totalActiveBalance > 0 && !_group.viewerIsDebtor) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Umumiy toʻlov (FIFO)', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Eng eski qarzdan boshlab avtomatik taqsimlanadi',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _payDownAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Summa', border: OutlineInputBorder(), isDense: true),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<PaymentMethod>(
                      initialValue: _payDownMethod,
                      decoration: const InputDecoration(labelText: "To'lov usuli", border: OutlineInputBorder(), isDense: true),
                      items: [
                        for (final method in PaymentMethod.immediateMethods)
                          DropdownMenuItem(value: method, child: Text(method.label)),
                      ],
                      onChanged: (value) => setState(() => _payDownMethod = value ?? _payDownMethod),
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Taqsimlanishi:', style: Theme.of(context).textTheme.labelLarge),
                      for (final (item, applied) in preview)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.createdAt.toLocal()}'.split(' ').first,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${CurrencyFormatter.format(applied, item.currency)}'
                                '${applied >= item.balance ? ' (yopiladi)' : ''}',
                              ),
                            ],
                          ),
                        ),
                      if (amount != null && amount > totalActiveBalance)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Summa jami qoldiqdan oshib ketmoqda',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                    ],
                    if (_payDownError != null) ...[
                      const SizedBox(height: 8),
                      Text(_payDownError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: (_isPayingDown || amount == null || amount <= 0 || amount > totalActiveBalance)
                          ? null
                          : () => _submitPayDown(amount),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _isPayingDown
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text("To'lovni tasdiqlash"),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Qarzlar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final item in _group.items)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.createdAt.toLocal()}'.split('.').first,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        DebtStatusBadge(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Jami: ${CurrencyFormatter.format(item.originalAmount, item.currency)}'),
                    Text(
                      'Qoldiq: ${CurrencyFormatter.format(item.balance, item.currency)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (item.dueDate != null)
                      Text(
                        "Muddat: ${'${item.dueDate!.toLocal()}'.split(' ').first}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (!item.isSettled && !_group.viewerIsDebtor) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => _recordSinglePayment(item),
                            child: const Text("To'lov"),
                          ),
                          if (item.kind == DebtKind.b2b) ...[
                            const SizedBox(width: 8),
                            OutlinedButton(onPressed: () => _closeDebt(item), child: const Text('Yopish')),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
