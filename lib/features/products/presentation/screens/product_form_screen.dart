import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/categories/presentation/widgets/category_picker_field.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/presentation/screens/master_catalog_picker_screen.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_write_params.dart';
import 'package:bsmart/features/products/domain/usecases/create_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/get_next_plu_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/update_product_usecase.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Create-or-edit product form. On create, offers a choice between a
/// catalog-linked product ("Add from Catalog" — name/description resolve
/// from the shared `MasterProduct`) and a fully custom one; on edit, this
/// choice is fixed (a product's catalog link is immutable after creation,
/// per `UpdateProductDto` never including `masterProductId`).
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.editingProduct});

  /// Non-null when editing an existing product.
  final Product? editingProduct;

  bool get isEditing => editingProduct != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late final FormGroup _form;
  MasterProduct? _linkedCatalogEntry;
  bool _isSubmitting = false;
  bool _isFetchingPlu = false;
  String? _errorMessage;
  DateTime? _expiryDate;
  bool _clearExpiryDate = false;

  bool get _isCatalogLinked => widget.isEditing ? widget.editingProduct!.isCatalogLinked : _linkedCatalogEntry != null;

  @override
  void initState() {
    super.initState();
    final product = widget.editingProduct;
    _expiryDate = product?.expiryDate;

    _form = FormGroup({
      'name': FormControl<String>(value: product?.name, validators: widget.isEditing ? [] : []),
      'description': FormControl<String>(value: product?.description),
      'price': FormControl<String>(value: _plain(product?.price), validators: [Validators.required]),
      'costPrice': FormControl<String>(value: _plain(product?.costPrice)),
      'currency': FormControl<Currency>(value: product?.currency ?? Currency.uzs),
      'stock': FormControl<String>(value: product == null ? '0' : null),
      'unit': FormControl<ProductUnit>(value: product?.unit),
      'sku': FormControl<String>(value: product?.sku),
      'barcode': FormControl<String>(value: product?.barcode),
      'plu': FormControl<String>(value: product?.plu),
      'categoryId': FormControl<String>(value: product?.categoryId),
      'isActive': FormControl<bool>(value: product?.isActive ?? true),
    });
  }

  /// 62000.0 → "62000", 2.5 → "2.5" (no trailing ".0" in the fields).
  static String? _plain(double? v) =>
      v == null ? null : (v == v.truncateToDouble() ? v.toStringAsFixed(0) : v.toString());

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _pickFromCatalog() async {
    final picked = await Navigator.of(
      context,
    ).push<MasterProduct>(MaterialPageRoute(builder: (_) => const MasterCatalogPickerScreen()));
    if (picked == null) return;
    setState(() {
      _linkedCatalogEntry = picked;
      _form.control('name').value = null;
      _form.control('description').value = null;
      if (picked.unit != null) _form.control('unit').value = picked.unit;
      if (picked.categoryId != null) _form.control('categoryId').value = picked.categoryId;
    });
  }

  void _clearCatalogLink() => setState(() => _linkedCatalogEntry = null);

  Future<void> _fetchNextPlu() async {
    setState(() => _isFetchingPlu = true);
    final result = await getIt<GetNextPluUseCase>().call();
    if (!mounted) return;
    setState(() {
      _isFetchingPlu = false;
      result.fold((plu) => _form.control('plu').value = plu, (_) {});
    });
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _clearExpiryDate = false;
      });
    }
  }

  double? _parseDouble(String key) {
    final raw = _form.control(key).value as String?;
    if (raw == null || raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _submit() async {
    if (_form.invalid || (!_isCatalogLinked && (_form.control('name').value as String?)?.isEmpty != false)) {
      _form.markAllAsTouched();
      setState(() => _errorMessage = _isCatalogLinked ? null : context.l10n.productsNameOrCatalog);
      return;
    }

    final price = _parseDouble('price');
    if (price == null) {
      setState(() => _errorMessage = context.l10n.productsPriceInvalid);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    if (widget.isEditing) {
      final result = await getIt<UpdateProductUseCase>().call(
        widget.editingProduct!.id,
        UpdateProductParams(
          name: _isCatalogLinked ? null : _form.control('name').value as String?,
          description: _isCatalogLinked ? null : _form.control('description').value as String?,
          price: price,
          costPrice: _parseDouble('costPrice'),
          unit: _form.control('unit').value as ProductUnit?,
          sku: _form.control('sku').value as String?,
          barcode: _form.control('barcode').value as String?,
          plu: _form.control('plu').value as String?,
          categoryId: _form.control('categoryId').value as String?,
          isActive: _form.control('isActive').value as bool?,
          expiryDate: _clearExpiryDate ? null : _expiryDate,
          clearExpiryDate: _clearExpiryDate,
        ),
      );
      if (!mounted) return;
      result.fold(
        (_) => context.pop(true),
        (failure) => setState(() {
          _isSubmitting = false;
          _errorMessage = failure.message;
        }),
      );
    } else {
      final result = await getIt<CreateProductUseCase>().call(
        CreateProductParams(
          name: _isCatalogLinked ? null : _form.control('name').value as String?,
          masterProductId: _linkedCatalogEntry?.id,
          description: _isCatalogLinked ? null : _form.control('description').value as String?,
          price: price,
          costPrice: _parseDouble('costPrice'),
          currency: _form.control('currency').value as Currency,
          stock: _parseDouble('stock') ?? 0,
          unit: _form.control('unit').value as ProductUnit?,
          sku: _form.control('sku').value as String?,
          barcode: _form.control('barcode').value as String?,
          plu: _form.control('plu').value as String?,
          categoryId: _form.control('categoryId').value as String?,
          expiryDate: _expiryDate,
        ),
      );
      if (!mounted) return;
      result.fold(
        (product) => context.pushReplacement('/products/${product.id}'),
        (failure) => setState(() {
          _isSubmitting = false;
          _errorMessage = failure.message;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return DashPage(
      title: widget.isEditing ? l10n.productsEditTitle : l10n.productsNewTitle,
      bottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                : Text(widget.isEditing ? l10n.commonSave : l10n.commonAdd),
          ),
        ),
      ),
      body: DashFormTheme(
        child: ReactiveForm(
          formGroup: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              DashSectionTitle(l10n.formBasics, padding: const EdgeInsets.fromLTRB(4, 8, 4, 10)),
              if (!widget.isEditing && !_isCatalogLinked) _buildSourcePicker(),
              if (_isCatalogLinked) _buildCatalogSummary() else _buildCustomNameFields(),
              DashSectionTitle(l10n.formPricing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ReactiveTextField<String>(
                      formControlName: 'price',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.commonPriceRequired),
                      validationMessages: {ValidationMessage.required: (_) => l10n.productsPriceRequired},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReactiveTextField<String>(
                      formControlName: 'costPrice',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.commonCostPrice),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.isEditing)
                InputDecorator(
                  decoration: InputDecoration(labelText: l10n.commonCurrency),
                  child: Text(
                    widget.editingProduct!.currency == Currency.uzs ? l10n.currencyUzsLong : l10n.currencyUsdLong,
                  ),
                )
              else
                ReactiveValueListenableBuilder<Currency>(
                  formControlName: 'currency',
                  builder: (context, control, _) => PillToggle<Currency>(
                    values: const [Currency.uzs, Currency.usd],
                    selected: control.value ?? Currency.uzs,
                    expand: true,
                    label: (c) => c == Currency.uzs ? l10n.currencyUzsLong : l10n.currencyUsdLong,
                    onChanged: (c) => control.value = c,
                  ),
                ),
              DashSectionTitle(l10n.formStockSection),
              ReactiveDropdownField<ProductUnit>(
                formControlName: 'unit',
                decoration: InputDecoration(labelText: l10n.commonUnit),
                items: [for (final unit in ProductUnit.values) DropdownMenuItem(value: unit, child: Text(unit.label))],
              ),
              const SizedBox(height: 12),
              if (!widget.isEditing)
                ReactiveTextField<String>(
                  formControlName: 'stock',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.productsInitialStock),
                )
              else
                DashCard(
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.productsStockEditHint(_plain(widget.editingProduct!.stock)!),
                          style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              DashSectionTitle(l10n.formExtra),
              const CategoryPickerField(formControlName: 'categoryId'),
              const SizedBox(height: 12),
              ReactiveTextField<String>(
                formControlName: 'barcode',
                decoration: InputDecoration(labelText: l10n.commonBarcode),
              ),
              const SizedBox(height: 12),
              ReactiveTextField<String>(
                formControlName: 'sku',
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ReactiveTextField<String>(
                      formControlName: 'plu',
                      decoration: const InputDecoration(labelText: 'PLU'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _isFetchingPlu ? null : _fetchNextPlu,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _isFetchingPlu
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.productsPluSuggest),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickExpiryDate,
                borderRadius: BorderRadius.circular(18),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.productsExpiryOptional,
                    suffixIcon: _expiryDate != null
                        ? IconButton(
                            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() {
                              _expiryDate = null;
                              _clearExpiryDate = true;
                            }),
                          )
                        : const Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    _expiryDate != null ? DateFormat('dd.MM.yyyy').format(_expiryDate!) : l10n.commonNotSelected,
                  ),
                ),
              ),
              if (widget.isEditing) ...[
                const SizedBox(height: 12),
                DashCard(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: ReactiveSwitchListTile(formControlName: 'isActive', title: Text(l10n.commonActive)),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourcePicker() {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashCard(
        onTap: _pickFromCatalog,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.brandYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.library_books_rounded, color: colors.accentText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.productsPickFromCatalog,
                style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogSummary() {
    final colors = BrandColors.of(context);
    final name = _linkedCatalogEntry?.name ?? widget.editingProduct?.name ?? '';
    final brand = _linkedCatalogEntry?.brand ?? widget.editingProduct?.brand;
    return DashCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.link_rounded, color: AppColors.onBrand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
                if (brand != null)
                  Text(
                    brand,
                    style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          if (!widget.isEditing)
            IconButton(
              tooltip: context.l10n.commonCancel,
              icon: const Icon(Icons.close_rounded),
              onPressed: _clearCatalogLink,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomNameFields() {
    return Column(
      children: [
        ReactiveTextField<String>(
          formControlName: 'name',
          decoration: InputDecoration(labelText: context.l10n.productsNameRequired),
        ),
        const SizedBox(height: 12),
        ReactiveTextField<String>(
          formControlName: 'description',
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(labelText: context.l10n.commonDescription),
        ),
      ],
    );
  }
}
