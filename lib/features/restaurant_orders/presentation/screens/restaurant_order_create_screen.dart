import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_write_params.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/create_restaurant_order_usecase.dart';
import 'package:bsmart/features/restaurant_tables/presentation/providers/restaurant_tables_list_notifier.dart';

class _CartLine {
  _CartLine({required this.productId, required this.productName, required this.unitPrice}) : quantity = 1;

  final String? productId;
  final String productName;
  final double unitPrice;
  int quantity;

  double get total => unitPrice * quantity;
}

/// Take a new dine-in or delivery order — mirrors the reference web app's
/// `RestaurantOrderCreateDrawer`. Menu-item search reuses the tenant's own
/// `features/products` (a restaurant's "Menu" is just its own inventory,
/// re-skinned — see `CLAUDE.md`), not a new product-picking concept.
class RestaurantOrderCreateScreen extends ConsumerStatefulWidget {
  const RestaurantOrderCreateScreen({super.key});

  @override
  ConsumerState<RestaurantOrderCreateScreen> createState() => _RestaurantOrderCreateScreenState();
}

class _RestaurantOrderCreateScreenState extends ConsumerState<RestaurantOrderCreateScreen> {
  RestaurantOrderType _type = RestaurantOrderType.dineIn;
  String? _tableId;
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final List<_CartLine> _cart = [];
  bool _isSaving = false;
  String? _errorMessage;

  double get _subtotal => _cart.fold(0, (sum, line) => sum + line.total);

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _deliveryAddressController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    final selected = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _MenuSearchSheet(),
    );
    if (selected == null) return;
    setState(() {
      final existingIndex = _cart.indexWhere((l) => l.productId == selected.id);
      if (existingIndex != -1) {
        _cart[existingIndex].quantity += 1;
      } else {
        _cart.add(_CartLine(productId: selected.id, productName: selected.name, unitPrice: selected.price));
      }
    });
  }

  Future<void> _submit() async {
    if (_cart.isEmpty) {
      setState(() => _errorMessage = 'Kamida bitta taom qo\'shing');
      return;
    }
    if (_type == RestaurantOrderType.dineIn && _tableId == null) {
      setState(() => _errorMessage = 'Stolni tanlang');
      return;
    }
    if (_type == RestaurantOrderType.delivery && _deliveryAddressController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Yetkazib berish manzilini kiriting');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final result = await getIt<CreateRestaurantOrderUseCase>().call(
      CreateRestaurantOrderParams(
        type: _type,
        tableId: _type == RestaurantOrderType.dineIn ? _tableId : null,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        deliveryAddress: _type == RestaurantOrderType.delivery ? _deliveryAddressController.text.trim() : null,
        notes: _notesController.text.trim(),
        items: [
          for (final line in _cart)
            RestaurantOrderItemInput(productId: line.productId, quantity: line.quantity, unitPrice: line.unitPrice),
        ],
        discount: double.tryParse(_discountController.text.trim()) ?? 0,
      ),
    );
    if (!mounted) return;
    result.fold(
      (_) => Navigator.of(context).pop(true),
      (failure) => setState(() {
        _isSaving = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(restaurantTablesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Yangi buyurtma')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<RestaurantOrderType>(
            segments: const [
              ButtonSegment(value: RestaurantOrderType.dineIn, label: Text('Zalda')),
              ButtonSegment(value: RestaurantOrderType.delivery, label: Text('Yetkazib berish')),
            ],
            selected: {_type},
            onSelectionChanged: (value) => setState(() => _type = value.first),
          ),
          const SizedBox(height: 12),
          if (_type == RestaurantOrderType.dineIn)
            tablesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Xatolik: $error'),
              data: (tables) => DropdownButtonFormField<String>(
                initialValue: _tableId,
                decoration: const InputDecoration(labelText: 'Stol *', border: OutlineInputBorder()),
                items: [for (final t in tables) DropdownMenuItem(value: t.id, child: Text(t.name))],
                onChanged: (value) => setState(() => _tableId = value),
              ),
            )
          else ...[
            TextFormField(
              controller: _deliveryAddressController,
              decoration: const InputDecoration(labelText: 'Manzil *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _customerNameController,
            decoration: const InputDecoration(labelText: 'Mijoz ismi', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _customerPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mijoz telefoni', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taomlar', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Qo\'shish')),
            ],
          ),
          if (_cart.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Hali taom qo\'shilmagan'))
          else
            for (final line in _cart)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(line.productName),
                subtitle: Text('${CurrencyFormatter.format(line.unitPrice, Currency.uzs)} x ${line.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setState(() {
                        if (line.quantity > 1) {
                          line.quantity -= 1;
                        } else {
                          _cart.remove(line);
                        }
                      }),
                    ),
                    Text('${line.quantity}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => line.quantity += 1),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Chegirma', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Izoh', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Oraliq summa', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(CurrencyFormatter.format(_subtotal, Currency.uzs)),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Buyurtma berish'),
          ),
        ],
      ),
    );
  }
}

class _MenuSearchSheet extends StatefulWidget {
  const _MenuSearchSheet();

  @override
  State<_MenuSearchSheet> createState() => _MenuSearchSheetState();
}

class _MenuSearchSheetState extends State<_MenuSearchSheet> {
  final _searchController = TextEditingController();
  List<Product> _results = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    setState(() => _isLoading = true);
    final result = await getIt<ListProductsUseCase>().call(ProductQuery(search: query, limit: 30, isActive: true));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      result.fold((page) => _results = page.data, (failure) => _results = const []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Menyudan qidirish...', border: OutlineInputBorder()),
                  onChanged: _runSearch,
                ),
              ),
              if (_isLoading) const LinearProgressIndicator(),
              Expanded(
                child: _results.isEmpty
                    ? const Center(child: Text('Hech narsa topilmadi'))
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = _results[index];
                          return ListTile(
                            title: Text(product.name),
                            trailing: Text(CurrencyFormatter.format(product.price, product.currency)),
                            onTap: () => Navigator.of(context).pop(product),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
