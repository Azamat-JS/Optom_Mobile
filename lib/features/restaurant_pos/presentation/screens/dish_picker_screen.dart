import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/presentation/providers/warehouse_providers.dart';
import 'package:bsmart/features/warehouse/presentation/widgets/warehouse_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

class _Line {
  _Line(this.product) : quantity = 1;

  final Product product;
  int quantity;
}

/// Picks dishes from the menu (Optom_Savdo "Restaurant POS"): tap a dish to add it, the stepper
/// changes the count. Used for a table's new order or second bill, for adding dishes to a bill,
/// and for a walk-in takeaway. [onSubmit] does the save; returning true closes the screen.
class DishPickerScreen extends ConsumerStatefulWidget {
  const DishPickerScreen({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.subtitle,
    this.askNote = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String submitLabel;

  /// Offers an order note (the API takes none when adding to an existing bill).
  final bool askNote;
  final Future<bool> Function(List<RestaurantOrderItemInput> items, String note) onSubmit;

  @override
  ConsumerState<DishPickerScreen> createState() => _DishPickerScreenState();
}

class _DishPickerScreenState extends ConsumerState<DishPickerScreen> {
  final _searchController = TextEditingController();
  final _noteController = TextEditingController();
  Timer? _debounce;
  List<Product> _products = const [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, _Line> _lines = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final query = _searchController.text.trim();
    final result = await getIt<ListProductsUseCase>().call(
      ProductQuery(search: query.isEmpty ? null : query, limit: 100, isActive: true),
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      result.fold((page) => _products = page.data, (failure) => _errorMessage = failure.message);
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _search);
  }

  void _add(Product product) {
    HapticFeedback.selectionClick();
    setState(() {
      final line = _lines[product.id];
      if (line == null) {
        _lines[product.id] = _Line(product);
      } else {
        line.quantity += 1;
      }
    });
  }

  void _setQuantity(Product product, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _lines.remove(product.id);
      } else {
        _lines[product.id]?.quantity = quantity;
      }
    });
  }

  int get _count => _lines.values.fold(0, (sum, l) => sum + l.quantity);
  double get _total => _lines.values.fold(0, (sum, l) => sum + l.quantity * l.product.price);

  Future<void> _submit() async {
    if (_lines.isEmpty || _isSaving) return;
    setState(() => _isSaving = true);
    final ok = await widget.onSubmit([
      for (final l in _lines.values)
        RestaurantOrderItemInput(productId: l.product.id, quantity: l.quantity, unitPrice: l.product.price),
    ], _noteController.text.trim());
    if (!mounted) return;
    if (ok) {
      _lines.clear();
      Navigator.of(context).pop(true);
    } else {
      setState(() => _isSaving = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.rposDiscardTitle),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.rposDiscardLeave)),
        ],
      ),
    );
    return leave == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final availability = ref.watch(dishAvailabilityProvider).valueOrNull ?? const <String, DishAvailabilityEntry>{};

    return PopScope(
      canPop: _lines.isEmpty || _isSaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          setState(_lines.clear);
          Navigator.of(context).pop();
        }
      },
      child: DashPage(
        title: widget.title,
        bottomBar: AnimatedOpacity(
          opacity: _lines.isEmpty || _isSaving ? 0.55 : 1,
          duration: const Duration(milliseconds: 150),
          child: DashCartBar(
            count: _count,
            countLabel: _lines.isEmpty ? l10n.rposPickDishes : l10n.restDishCount(_count),
            total: CurrencyFormatter.format(_total, Currency.uzs),
            actionLabel: widget.submitLabel,
            onTap: _submit,
          ),
        ),
        body: Column(
          children: [
            if (widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.subtitle!,
                    style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: DashSearchField(
                controller: _searchController,
                hint: l10n.restMenuSearchHint,
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(child: _buildList(availability)),
            if (widget.askNote)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _noteController,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: l10n.commonNoteOptional,
                    counterText: '',
                    isDense: true,
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    filled: true,
                    fillColor: colors.field,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(Map<String, DishAvailabilityEntry> availability) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    if (_errorMessage != null) {
      return DashEmptyState(
        icon: Icons.cloud_off_rounded,
        text: _errorMessage!,
        action: TextButton(onPressed: _search, child: Text(l10n.commonRetry)),
      );
    }
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_products.isEmpty) return DashEmptyState(icon: Icons.restaurant_menu_rounded, text: l10n.commonNothingFound);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final product = _products[index];
        final line = _lines[product.id];
        final dish = availability[product.id];
        return DashCard(
          onTap: () => _add(product),
          outlineColor: line != null ? AppColors.brandYellow : null,
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          child: Row(
            children: [
              DashThumb(url: product.primaryImage?.url, icon: Icons.restaurant_menu_rounded, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(product.price, product.currency),
                      style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                    if (dish != null && dish.status != DishStatus.noRecipe) ...[
                      const SizedBox(height: 4),
                      DishAvailabilityTag(status: dish.status, portions: dish.portions),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              line == null
                  ? Icon(Icons.add_circle_rounded, size: 30, color: colors.textMuted)
                  : DashStepper(
                      value: '${line.quantity}',
                      onMinus: () => _setQuantity(product, line.quantity - 1),
                      onPlus: () => _setQuantity(product, line.quantity + 1),
                    ),
            ],
          ),
        );
      },
    );
  }
}
