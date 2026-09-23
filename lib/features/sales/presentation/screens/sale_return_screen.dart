import 'package:flutter/material.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/usecases/create_sale_return_usecase.dart';

/// Return part or all of a sale — mirrors `CreateSaleReturnDto` exactly.
/// `refundMethod` is required only when the original sale was PAID (a DEBT
/// sale's return just reduces the linked `SaleDebt` balance, see
/// `sale.service.ts#createReturn`).
class SaleReturnScreen extends StatefulWidget {
  const SaleReturnScreen({super.key, required this.sale});

  final Sale sale;

  @override
  State<SaleReturnScreen> createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends State<SaleReturnScreen> {
  final _quantities = <String, double>{};
  final _reasonController = TextEditingController();
  PaymentMethod _refundMethod = PaymentMethod.cash;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  double get _totalReturnAmount {
    double sum = 0;
    for (final item in widget.sale.items) {
      final qty = _quantities[item.id] ?? 0;
      if (qty <= 0) continue;
      final unitValue = item.total / item.quantity;
      sum += unitValue * qty;
    }
    return sum;
  }

  Future<void> _submit() async {
    final items = [
      for (final item in widget.sale.items)
        if ((_quantities[item.id] ?? 0) > 0)
          CreateSaleReturnItemParams(saleItemId: item.id, quantity: _quantities[item.id]!),
    ];
    if (items.isEmpty) {
      setState(() => _errorMessage = 'Qaytariladigan mahsulotni tanlang');
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await getIt<CreateSaleReturnUseCase>().call(
      widget.sale.id,
      CreateSaleReturnParams(
        items: items,
        reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
        refundMethod: widget.sale.type == SaleType.paid ? _refundMethod : null,
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
    final returnableItems = widget.sale.items.where((i) => i.remainingReturnable > 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Qaytarish')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in returnableItems)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName),
                          Text(
                            'Qoldi: ${item.remainingReturnable.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        final current = _quantities[item.id] ?? 0;
                        if (current > 0) setState(() => _quantities[item.id] = current - 1);
                      },
                    ),
                    Text((_quantities[item.id] ?? 0).toStringAsFixed(0)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        final current = _quantities[item.id] ?? 0;
                        if (current < item.remainingReturnable) {
                          setState(() => _quantities[item.id] = current + 1);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(labelText: 'Sababi (ixtiyoriy)', border: OutlineInputBorder()),
          ),
          if (widget.sale.type == SaleType.paid) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _refundMethod,
              decoration: const InputDecoration(labelText: 'Pulni qaytarish usuli', border: OutlineInputBorder()),
              items: [
                for (final method in PaymentMethod.immediateMethods)
                  DropdownMenuItem(value: method, child: Text(method.label)),
              ],
              onChanged: (value) => setState(() => _refundMethod = value ?? _refundMethod),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Qaytariladigan summa: ${CurrencyFormatter.format(_totalReturnAmount, widget.sale.currency)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Qaytarishni tasdiqlash'),
          ),
        ),
      ),
    );
  }
}
