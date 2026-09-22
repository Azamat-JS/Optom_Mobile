import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';
import 'package:bsmart/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:bsmart/features/orders/presentation/providers/create_order_cart_notifier.dart';
import 'package:bsmart/features/orders/presentation/providers/orders_list_notifier.dart';

/// Step 3: review the cart, add notes/delivery address, and submit
/// (`POST /orders`).
class OrderReviewScreen extends ConsumerStatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  ConsumerState<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends ConsumerState<OrderReviewScreen> {
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cart = ref.read(createOrderCartProvider);
    if (cart.seller == null || cart.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await getIt<CreateOrderUseCase>().call(
      CreateOrderParams(
        sellerId: cart.seller!.id,
        items: [
          for (final line in cart.lines.values)
            CreateOrderItemParams(
              productId: line.product.id,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
              discount: line.discount > 0 ? line.discount : null,
            ),
        ],
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        deliveryAddress: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      ),
    );

    if (!mounted) return;
    result.fold(
      (order) {
        ref.read(createOrderCartProvider.notifier).clear();
        ref.invalidate(ordersListProvider);
        context.go(RouteNames.orderDetail(order.id));
      },
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(createOrderCartProvider);
    final currency = cart.lines.isEmpty ? null : cart.lines.values.first.product.currency;

    return Scaffold(
      appBar: AppBar(title: const Text("Buyurtmani ko'rib chiqish")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cart.seller != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: Text(cart.seller!.fullName),
                subtitle: cart.store != null ? Text(cart.store!.name) : null,
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final line in cart.lines.values)
                  ListTile(
                    title: Text(line.product.name),
                    subtitle: Text(
                      '${line.quantity.toStringAsFixed(line.product.unit?.isWeighable ?? false ? 2 : 0)} ${line.product.unit?.label ?? ''} × ${CurrencyFormatter.format(line.unitPrice, line.product.currency)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(CurrencyFormatter.format(line.total, line.product.currency)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () =>
                              ref.read(createOrderCartProvider.notifier).removeProduct(line.product.id),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Yetkazib berish manzili', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Izoh', border: OutlineInputBorder()),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jami', style: Theme.of(context).textTheme.titleMedium),
              Text(
                currency != null ? CurrencyFormatter.format(cart.total, currency) : '-',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSubmitting || cart.isEmpty ? null : _submit,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Buyurtma berish'),
          ),
        ],
      ),
    );
  }
}
