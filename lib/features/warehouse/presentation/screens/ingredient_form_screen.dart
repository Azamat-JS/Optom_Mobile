import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/ingredient_unit.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/usecases/create_ingredient_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/update_ingredient_usecase.dart';
import 'package:bsmart/features/warehouse/domain/warehouse_math.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Create or edit a warehouse ingredient. The unit is fixed once created (recipes and the whole
/// stock history are in it). On create, the stock on hand and its price can be entered at once:
/// the server records them as the opening receipt and its average cost.
class IngredientFormScreen extends ConsumerStatefulWidget {
  const IngredientFormScreen({super.key, this.editing});

  final Ingredient? editing;

  @override
  ConsumerState<IngredientFormScreen> createState() => _IngredientFormScreenState();
}

class _IngredientFormScreenState extends ConsumerState<IngredientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.editing?.name);
  late final _minStock = TextEditingController(text: _plain(widget.editing?.minStock));
  final _initialQty = TextEditingController();
  final _initialCost = TextEditingController();
  late final _notes = TextEditingController(text: widget.editing?.notes);
  late IngredientUnit _unit = widget.editing?.unit ?? IngredientUnit.kilogram;
  late bool _active = widget.editing?.isActive ?? true;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.editing != null;

  static String _plain(double? v) {
    if (v == null || v == 0) return '';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString().replaceAll('.', ',');
  }

  @override
  void dispose() {
    for (final c in [_name, _minStock, _initialQty, _initialCost, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _amountValidator(String? v, {int decimals = 4}) {
    if (v == null || v.trim().isEmpty) return null;
    return parseAmount(v, maxDecimals: decimals) == null ? context.l10n.whAmountInvalid : null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final name = _name.text.trim();
    final minStock = parseAmount(_minStock.text);
    final notes = _notes.text.trim();
    final result = _isEdit
        ? await getIt<UpdateIngredientUseCase>().call(
            widget.editing!.id,
            UpdateIngredientParams(name: name, minStock: minStock ?? 0, isActive: _active, notes: notes),
          )
        : await getIt<CreateIngredientUseCase>().call(
            CreateIngredientParams(
              name: name,
              unit: _unit,
              minStock: minStock,
              notes: notes,
              initialQuantity: parseAmount(_initialQty.text),
              initialUnitCost: parseAmount(_initialCost.text, maxDecimals: 2),
            ),
          );
    if (!mounted) return;
    result.fold(
      (_) => Navigator.of(context).pop(true),
      (failure) => setState(() {
        _saving = false;
        _error = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final unitShort = _unit.shortLabel;
    return DashPage(
      title: _isEdit ? l10n.whEditTitle : l10n.whNewTitle,
      bottomBar: DashBottomButton(label: l10n.commonSave, busy: _saving, onPressed: _submit),
      body: DashFormTheme(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // Not a lazy ListView: a field scrolled out of a ListView is unmounted, and
          // FormState.validate() then skips it (an empty name went through).
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.whName,
                    hintText: l10n.whNameHint,
                    prefixIcon: const Icon(Icons.kitchen_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.whNameRequired : null,
                ),
                DashSectionTitle(l10n.whUnit, padding: const EdgeInsets.fromLTRB(4, 18, 4, 10)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final unit in IngredientUnit.values)
                      ChoiceChip(
                        label: Text(unit.label),
                        selected: unit == _unit,
                        selectedColor: AppColors.brandYellow,
                        labelStyle: TextStyle(
                          color: unit == _unit ? AppColors.onBrand : colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: _isEdit ? null : (_) => setState(() => _unit = unit),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                  child: Text(
                    _isEdit ? l10n.whUnitLocked : l10n.whUnitHint,
                    style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _minStock,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.whMinStock(unitShort),
                    helperText: l10n.whMinStockHint,
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.warning_amber_rounded),
                  ),
                  validator: _amountValidator,
                ),
                if (!_isEdit) ...[
                  DashSectionTitle(l10n.whOpeningTitle, padding: const EdgeInsets.fromLTRB(4, 18, 4, 4)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                    child: Text(
                      l10n.whOpeningHint,
                      style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextFormField(
                    controller: _initialQty,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.whStockOnHand(unitShort),
                      prefixIcon: const Icon(Icons.inventory_rounded),
                    ),
                    validator: _amountValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _initialCost,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.whPricePerUnit(unitShort),
                      prefixIcon: const Icon(Icons.payments_rounded),
                    ),
                    validator: (v) {
                      final invalid = _amountValidator(v, decimals: 2);
                      if (invalid != null) return invalid;
                      // The server ignores a price without stock: say so instead of dropping it.
                      if ((v?.trim().isNotEmpty ?? false) && (parseAmount(_initialQty.text) ?? 0) <= 0) {
                        return l10n.whPriceNeedsStock;
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.commonNote,
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                ),
                if (_isEdit) ...[
                  const SizedBox(height: 12),
                  DashCard(
                    padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _active,
                      onChanged: (v) => setState(() => _active = v),
                      title: Text(l10n.commonActive, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(l10n.whActiveHint),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
