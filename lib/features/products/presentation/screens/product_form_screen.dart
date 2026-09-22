import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/features/categories/presentation/widgets/category_picker_field.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/presentation/screens/master_catalog_picker_screen.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_write_params.dart';
import 'package:bsmart/features/products/domain/usecases/create_product_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/get_next_plu_usecase.dart';
import 'package:bsmart/features/products/domain/usecases/update_product_usecase.dart';

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

  bool get _isCatalogLinked => widget.isEditing
      ? widget.editingProduct!.isCatalogLinked
      : _linkedCatalogEntry != null;

  @override
  void initState() {
    super.initState();
    final product = widget.editingProduct;
    _expiryDate = product?.expiryDate;

    _form = FormGroup({
      'name': FormControl<String>(value: product?.name, validators: widget.isEditing ? [] : []),
      'description': FormControl<String>(value: product?.description),
      'price': FormControl<String>(value: product?.price.toString(), validators: [Validators.required]),
      'costPrice': FormControl<String>(value: product?.costPrice?.toString()),
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

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _pickFromCatalog() async {
    final picked = await Navigator.of(context).push<MasterProduct>(
      MaterialPageRoute(builder: (_) => const MasterCatalogPickerScreen()),
    );
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
      setState(() => _errorMessage = _isCatalogLinked ? null : 'Mahsulot nomini kiriting yoki katalogdan tanlang');
      return;
    }

    final price = _parseDouble('price');
    if (price == null) {
      setState(() => _errorMessage = "Narx noto'g'ri kiritildi");
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Mahsulotni tahrirlash' : 'Yangi mahsulot')),
      body: ReactiveForm(
        formGroup: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!widget.isEditing) _buildSourcePicker(),
            if (_isCatalogLinked) _buildCatalogSummary() else _buildCustomNameFields(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ReactiveTextField<String>(
                    formControlName: 'price',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Narx *', border: OutlineInputBorder()),
                    validationMessages: {ValidationMessage.required: (_) => 'Narx kiritilishi shart'},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ReactiveTextField<String>(
                    formControlName: 'costPrice',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Tannarx', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.isEditing)
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Valyuta', border: OutlineInputBorder()),
                child: Text((widget.editingProduct!.currency == Currency.uzs) ? "So'm (UZS)" : 'Dollar (USD)'),
              )
            else
              ReactiveDropdownField<Currency>(
                formControlName: 'currency',
                decoration: const InputDecoration(labelText: 'Valyuta *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: Currency.uzs, child: Text("So'm (UZS)")),
                  DropdownMenuItem(value: Currency.usd, child: Text('Dollar (USD)')),
                ],
              ),
            const SizedBox(height: 12),
            ReactiveDropdownField<ProductUnit>(
              formControlName: 'unit',
              decoration: const InputDecoration(labelText: "O'lchov birligi", border: OutlineInputBorder()),
              items: [for (final unit in ProductUnit.values) DropdownMenuItem(value: unit, child: Text(unit.label))],
            ),
            const SizedBox(height: 12),
            if (!widget.isEditing)
              ReactiveTextField<String>(
                formControlName: 'stock',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Boshlang\'ich zaxira', border: OutlineInputBorder()),
              )
            else
              InputDecorator(
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Zaxira'),
                child: Text(
                  '${widget.editingProduct!.stock} — o\'zgartirish uchun mahsulot sahifasidagi "Zaxira qo\'shish" tugmasini ishlating',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            const CategoryPickerField(formControlName: 'categoryId'),
            const SizedBox(height: 12),
            ReactiveTextField<String>(
              formControlName: 'sku',
              decoration: const InputDecoration(labelText: 'SKU', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ReactiveTextField<String>(
              formControlName: 'barcode',
              decoration: const InputDecoration(labelText: 'Shtrix-kod', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ReactiveTextField<String>(
                    formControlName: 'plu',
                    decoration: const InputDecoration(labelText: 'PLU', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton(
                    onPressed: _isFetchingPlu ? null : _fetchNextPlu,
                    child: _isFetchingPlu
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Taklif'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickExpiryDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Yaroqlilik muddati (ixtiyoriy)',
                  border: const OutlineInputBorder(),
                  suffixIcon: _expiryDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() {
                            _expiryDate = null;
                            _clearExpiryDate = true;
                          }),
                        )
                      : const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(_expiryDate != null ? _expiryDate!.toIso8601String().split('T').first : 'Tanlanmagan'),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 12),
              ReactiveSwitchListTile(formControlName: 'isActive', title: const Text('Faol')),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.isEditing ? 'Saqlash' : "Qo'shish"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourcePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickFromCatalog,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Katalogdan tanlash'),
            ),
          ),
          const SizedBox(width: 8),
          if (_linkedCatalogEntry != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Bekor qilish',
              onPressed: _clearCatalogLink,
            ),
        ],
      ),
    );
  }

  Widget _buildCatalogSummary() {
    final name = _linkedCatalogEntry?.name ?? widget.editingProduct?.name ?? '';
    final brand = _linkedCatalogEntry?.brand ?? widget.editingProduct?.brand;
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: const Icon(Icons.link),
        title: Text(name),
        subtitle: brand != null ? Text(brand) : null,
        trailing: !widget.isEditing
            ? IconButton(icon: const Icon(Icons.close), onPressed: _clearCatalogLink)
            : null,
      ),
    );
  }

  Widget _buildCustomNameFields() {
    return Column(
      children: [
        ReactiveTextField<String>(
          formControlName: 'name',
          decoration: const InputDecoration(labelText: 'Mahsulot nomi *', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        ReactiveTextField<String>(
          formControlName: 'description',
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Tavsif', border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
