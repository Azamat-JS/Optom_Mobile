import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/usecases/create_sale_usecase.dart';
import 'package:bsmart/features/sales/presentation/providers/pos_cart_notifier.dart';
import 'package:bsmart/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:bsmart/features/sales/presentation/widgets/customer_picker_sheet.dart';

/// POS checkout — pick a customer, choose PAID (+ payment method) or DEBT
/// (+ optional up-front `paidAmount`/due date), apply a sale-level discount,
/// then submit. Mirrors `CreateSaleDto` exactly (see `sale.service.ts`).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  Customer? _customer;
  SaleType _type = SaleType.paid;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final _discountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _discountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final picked = await CustomerPickerSheet.show(context);
    if (picked != null) setState(() => _customer = picked);
  }

  Future<void> _submit() async {
    final cart = ref.read(posCartProvider);
    if (cart.isEmpty) return;
    if (_customer == null) {
      setState(() => _errorMessage = 'Mijozni tanlang');
      return;
    }

    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final paidAmount = double.tryParse(_paidAmountController.text.trim()) ?? 0;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final params = CreateSaleParams(
      customerId: _customer!.id,
      type: _type,
      paymentMethod: _type == SaleType.paid ? _paymentMethod : (paidAmount > 0 ? _paymentMethod : null),
      items: cart.lines.values
          .map((line) => CreateSaleItemParams(productId: line.product.id, quantity: line.quantity, discount: line.discount))
          .toList(),
      discount: discount,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      paidAmount: _type == SaleType.debt ? paidAmount : null,
    );

    final result = await getIt<CreateSaleUseCase>().call(params);
    if (!mounted) return;
    result.fold(
      (sale) {
        ref.read(posCartProvider.notifier).clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SaleDetailScreen(saleId: sale.id, justCreated: true)),
        );
      },
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartProvider);
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    final total = (cart.subtotal - discount).clamp(0, double.infinity);
    final paidAmount = double.tryParse(_paidAmountController.text.trim()) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("To'lov")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(_customer?.fullName ?? 'Mijozni tanlang'),
              subtitle: _customer != null ? Text(_customer!.phone ?? '') : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickCustomer,
            ),
          ),
          const SizedBox(height: 16),
          Text('Mahsulotlar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final line in cart.lines.values)
                  ListTile(
                    dense: true,
                    title: Text(line.product.name),
                    subtitle: Text('${line.quantity.toStringAsFixed(0)} x ${CurrencyFormatter.format(line.product.price, line.product.currency)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                          onPressed: () =>
                              ref.read(posCartProvider.notifier).updateQuantity(line.product.id, line.quantity - 1),
                        ),
                        Text(line.quantity.toStringAsFixed(0)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          onPressed: () =>
                              ref.read(posCartProvider.notifier).updateQuantity(line.product.id, line.quantity + 1),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Chegirma', border: OutlineInputBorder(), isDense: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          SegmentedButton<SaleType>(
            segments: const [
              ButtonSegment(value: SaleType.paid, label: Text("To'landi"), icon: Icon(Icons.payments_outlined)),
              ButtonSegment(value: SaleType.debt, label: Text('Qarzga'), icon: Icon(Icons.receipt_long_outlined)),
            ],
            selected: {_type},
            onSelectionChanged: (selection) => setState(() => _type = selection.first),
          ),
          const SizedBox(height: 12),
          if (_type == SaleType.paid) ...[
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: "To'lov usuli", border: OutlineInputBorder(), isDense: true),
              items: [
                for (final method in PaymentMethod.immediateMethods)
                  DropdownMenuItem(value: method, child: Text(method.label)),
              ],
              onChanged: (value) => setState(() => _paymentMethod = value ?? _paymentMethod),
            ),
          ] else ...[
            TextField(
              controller: _paidAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Oldindan to'lov (ixtiyoriy)",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (paidAmount > 0) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: "To'lov usuli", border: OutlineInputBorder(), isDense: true),
                items: [
                  for (final method in PaymentMethod.immediateMethods)
                    DropdownMenuItem(value: method, child: Text(method.label)),
                ],
                onChanged: (value) => setState(() => _paymentMethod = value ?? _paymentMethod),
              ),
            ],
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Izoh', border: OutlineInputBorder(), isDense: true),
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
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Tasdiqlash — ${CurrencyFormatter.format(total.toDouble(), cart.currency!)}'),
          ),
        ),
      ),
    );
  }
}
