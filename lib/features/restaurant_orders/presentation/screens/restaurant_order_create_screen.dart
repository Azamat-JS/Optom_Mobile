import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_write_params.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/create_restaurant_order_usecase.dart';
import 'package:bsmart/features/restaurant_tables/presentation/providers/restaurant_tables_list_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/location_picker_field.dart';

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
  GeoPoint? _dropoff;
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
        deliveryPoint: _type == RestaurantOrderType.delivery ? _dropoff : null,
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
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final tablesAsync = ref.watch(restaurantTablesListProvider);
    final count = _cart.fold<int>(0, (sum, line) => sum + line.quantity);

    return DashPage(
      title: 'Yangi buyurtma',
      bottomBar: AnimatedOpacity(
        opacity: _isSaving ? 0.6 : 1,
        duration: AppMotion.standard,
        child: DashCartBar(
          count: count,
          countLabel: l10n.commonSubtotal,
          total: CurrencyFormatter.format(_subtotal, Currency.uzs),
          actionLabel: 'Buyurtma berish',
          onTap: _isSaving ? () {} : _submit,
        ),
      ),
      body: DashFormTheme(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            PillToggle<RestaurantOrderType>(
              values: const [RestaurantOrderType.dineIn, RestaurantOrderType.delivery],
              selected: _type,
              label: (t) => t.label,
              onChanged: (t) => setState(() => _type = t),
              expand: true,
            ),
            if (_type == RestaurantOrderType.dineIn) ...[
              const DashSectionTitle('Stol *'),
              tablesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text(l10n.commonErrorWith('$error')),
                data: (tables) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in tables)
                      _TablePill(
                        name: t.name,
                        selected: t.id == _tableId,
                        onTap: () => setState(() => _tableId = t.id),
                      ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _deliveryAddressController,
                decoration: const InputDecoration(labelText: 'Manzil *'),
              ),
              const SizedBox(height: 10),
              LocationPickerField(
                value: _dropoff,
                onChanged: (p) => setState(() => _dropoff = p),
                pickerTitle: 'Yetkazib berish joyi',
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Mijoz ismi'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _customerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mijoz telefoni'),
            ),
            DashSectionTitle(
              'Taomlar',
              trailing: TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.commonAdd),
              ),
            ),
            if (_cart.isEmpty)
              DashCard(
                onTap: _addItem,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu_rounded, size: 34, color: colors.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      "Hali taom qo'shilmagan",
                      style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
            else
              DashCard(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Column(
                  children: [
                    for (final (i, line) in _cart.indexed) ...[
                      if (i > 0) Divider(height: 20, color: colors.outline),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.productName,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(line.unitPrice, Currency.uzs),
                                  style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          DashStepper(
                            value: '${line.quantity}',
                            onMinus: () => setState(() {
                              if (line.quantity > 1) {
                                line.quantity -= 1;
                              } else {
                                _cart.remove(line);
                              }
                            }),
                            onPlus: () => setState(() => line.quantity += 1),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _discountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.commonDiscount),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: l10n.commonNote),
              maxLines: 2,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A table to pick for a dine-in order (selected = yellow).
class _TablePill extends StatelessWidget {
  const _TablePill({required this.name, required this.selected, required this.onTap});

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.brandYellow : DashColors.card(context),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.table_restaurant_rounded,
                  size: 18,
                  color: selected ? AppColors.onBrand : colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: TextStyle(
                    color: selected ? AppColors.onBrand : colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
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
  Timer? _debounce;
  List<Product> _results = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _runSearch(value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.navMenu,
                    style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Menyudan qidirish...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: colors.field,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                    ? Center(
                        child: Text(
                          l10n.commonNothingFound,
                          style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final product = _results[index];
                          return ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            leading: DashThumb(
                              url: product.primaryImage?.url,
                              icon: Icons.restaurant_menu_rounded,
                              size: 44,
                            ),
                            title: Text(
                              product.name,
                              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
                            ),
                            trailing: Text(
                              CurrencyFormatter.format(product.price, product.currency),
                              style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                            ),
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
