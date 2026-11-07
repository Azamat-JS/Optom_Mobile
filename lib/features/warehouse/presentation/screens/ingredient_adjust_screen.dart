import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/usecases/adjust_ingredient_usecase.dart';
import 'package:bsmart/features/warehouse/domain/warehouse_math.dart';
import 'package:bsmart/features/warehouse/presentation/widgets/warehouse_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Sanoq": set the stock to what was counted. "Hisobdan chiqarish": take spoiled goods off.
/// Both land in the ingredient's history.
class IngredientAdjustScreen extends ConsumerStatefulWidget {
  const IngredientAdjustScreen({required this.ingredient, super.key});

  final Ingredient ingredient;

  @override
  ConsumerState<IngredientAdjustScreen> createState() => _IngredientAdjustScreenState();
}

class _IngredientAdjustScreenState extends ConsumerState<IngredientAdjustScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qty = TextEditingController();
  final _note = TextEditingController();
  AdjustMode _mode = AdjustMode.count;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _qty.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await getIt<AdjustIngredientUseCase>().call(
      widget.ingredient.id,
      AdjustIngredientParams(mode: _mode, quantity: parseAmount(_qty.text)!, note: _note.text.trim()),
    );
    if (!mounted) return;
    final l10n = context.l10n;
    result.fold(
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_mode == AdjustMode.count ? l10n.whCountDone : l10n.whWasteDone)));
        Navigator.of(context).pop(true);
      },
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
    final ing = widget.ingredient;
    final unit = ing.unit.shortLabel;
    final value = parseAmount(_qty.text);
    final diff = value == null ? null : (_mode == AdjustMode.count ? value - ing.stock : -value);

    return DashPage(
      title: l10n.whAdjustTitle(ing.name),
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
                PillToggle<AdjustMode>(
                  expand: true,
                  values: AdjustMode.values,
                  selected: _mode,
                  label: (m) => m == AdjustMode.count ? l10n.whCount : l10n.whWaste,
                  onChanged: (m) => setState(() => _mode = m),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 14),
                  child: Text(
                    _mode == AdjustMode.count ? l10n.whCountHint : l10n.whWasteHint,
                    style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                DashCard(
                  child: DashInfoRow(label: l10n.whInStock, value: formatIngredientQty(ing.stock, ing.unit)),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _qty,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: _mode == AdjustMode.count ? l10n.whCounted(unit) : l10n.whWasted(unit),
                    prefixIcon: const Icon(Icons.scale_rounded),
                  ),
                  validator: (v) {
                    final parsed = parseAmount(v ?? '');
                    if (parsed == null) return l10n.whAmountInvalid;
                    if (_mode == AdjustMode.waste && parsed <= 0) return l10n.whAmountPositive;
                    if (_mode == AdjustMode.count && (parsed - ing.stock).abs() < 0.00005) return l10n.whCountSame;
                    return null;
                  },
                ),
                if (diff != null && diff.abs() >= 0.00005) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      l10n.whChange('${diff > 0 ? '+' : ''}${formatIngredientQty(diff, ing.unit)}'),
                      style: TextStyle(
                        color: diff < 0 ? Theme.of(context).colorScheme.error : warehouseGreen,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _note,
                  decoration: InputDecoration(
                    labelText: l10n.commonNote,
                    hintText: _mode == AdjustMode.waste ? l10n.whWasteNoteHint : null,
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                ),
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
