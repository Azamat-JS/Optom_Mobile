import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_write_params.dart';
import 'package:bsmart/features/products/domain/usecases/receive_stock_usecase.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Quick stock-adjust sheet — deliberately separate from the full edit form
/// (per the implementation plan): receiving new stock is the most frequent
/// operator action on a product, so it gets its own fast path instead of
/// requiring a trip through the whole edit form.
///
/// Returns the updated [Product] on success, or `null` if cancelled.
class StockAdjustSheet extends StatefulWidget {
  const StockAdjustSheet({super.key, required this.product});

  final Product product;

  @override
  State<StockAdjustSheet> createState() => _StockAdjustSheetState();
}

class _StockAdjustSheetState extends State<StockAdjustSheet> {
  late final FormGroup _form = FormGroup({
    'quantity': FormControl<String>(validators: [Validators.required]),
    'correction': FormControl<String>(),
  });

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final quantity = double.tryParse(_form.control('quantity').value as String? ?? '') ?? 0;
    final correctionRaw = _form.control('correction').value as String?;
    final correction = correctionRaw != null && correctionRaw.isNotEmpty ? double.tryParse(correctionRaw) : null;

    final result = await getIt<ReceiveStockUseCase>().call(
      widget.product.id,
      ReceiveStockParams(quantity: quantity, stockCorrection: correction),
    );

    if (!mounted) return;
    result.fold(
      (product) => Navigator.of(context).pop(product),
      (failure) => setState(() {
        _isSubmitting = false;
        _errorMessage = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeighable = widget.product.unit?.isWeighable ?? false;
    final colors = BrandColors.of(context);
    return DashFormTheme(
      onSheet: true,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 22, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: ReactiveForm(
          formGroup: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.productsAddStock,
                style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: DashTag(
                  label: context.l10n.productsCurrentStock(
                    '${widget.product.stock.toStringAsFixed(isWeighable ? 2 : 0)} ${widget.product.unit?.shortLabel ?? ''}',
                  ),
                  color: colors.accentText,
                ),
              ),
              const SizedBox(height: 16),
              ReactiveTextField<String>(
                formControlName: 'quantity',
                keyboardType: TextInputType.numberWithOptions(decimal: isWeighable),
                decoration: InputDecoration(labelText: context.l10n.productsAddQuantity),
                validationMessages: {ValidationMessage.required: (_) => context.l10n.commonQuantityRequired},
              ),
              const SizedBox(height: 12),
              ReactiveTextField<String>(
                formControlName: 'correction',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  labelText: context.l10n.productsCorrectionOptional,
                  helperText: context.l10n.productsCorrectionHint,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(context.l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
