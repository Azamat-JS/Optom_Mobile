import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/usecases/receive_ingredient_usecase.dart';
import 'package:bsmart/features/warehouse/domain/warehouse_math.dart';
import 'package:bsmart/features/warehouse/presentation/widgets/warehouse_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

enum _PriceMode { unit, total }

/// "Kirim": goods received from a supplier. The price may be typed per unit or for the whole
/// delivery (or left out); the server keeps a weighted average cost per unit.
class IngredientReceiveScreen extends ConsumerStatefulWidget {
  const IngredientReceiveScreen({required this.ingredient, super.key});

  final Ingredient ingredient;

  @override
  ConsumerState<IngredientReceiveScreen> createState() => _IngredientReceiveScreenState();
}

class _IngredientReceiveScreenState extends ConsumerState<IngredientReceiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qty = TextEditingController();
  final _price = TextEditingController();
  final _note = TextEditingController();
  _PriceMode _mode = _PriceMode.unit;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _qty.addListener(() => setState(() {}));
    _price.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _qty.dispose();
    _price.dispose();
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
    final price = parseAmount(_price.text, maxDecimals: 2);
    final result = await getIt<ReceiveIngredientUseCase>().call(
      widget.ingredient.id,
      ReceiveIngredientParams(
        quantity: parseAmount(_qty.text)!,
        unitCost: _mode == _PriceMode.unit ? price : null,
        totalCost: _mode == _PriceMode.total ? price : null,
        note: _note.text.trim(),
      ),
    );
    if (!mounted) return;
    result.fold(
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.whReceiveDone(widget.ingredient.name))));
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
    final q = parseAmount(_qty.text) ?? 0;
    final p = parseAmount(_price.text, maxDecimals: 2);
    final unitPrice = p == null || q <= 0 ? null : (_mode == _PriceMode.unit ? p : p / q);
    final totalPrice = p == null || q <= 0 ? null : (_mode == _PriceMode.unit ? p * q : p);

    return DashPage(
      title: l10n.whReceiveTitle(ing.name),
      bottomBar: DashBottomButton(label: l10n.whReceiveSubmit, busy: _saving, onPressed: _submit),
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
                DashCard(
                  child: Column(
                    children: [
                      DashInfoRow(label: l10n.whInStock, value: formatIngredientQty(ing.stock, ing.unit)),
                      if (ing.avgCost != null)
                        DashInfoRow(label: l10n.whAvgCost, value: l10n.whAvgPerUnit(formatSom(ing.avgCost!), unit)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _qty,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.whReceiveQty(unit),
                    prefixIcon: const Icon(Icons.add_box_rounded),
                  ),
                  validator: (v) {
                    final value = parseAmount(v ?? '');
                    if (value == null) return l10n.whAmountInvalid;
                    if (value <= 0) return l10n.whAmountPositive;
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                PillToggle<_PriceMode>(
                  expand: true,
                  values: _PriceMode.values,
                  selected: _mode,
                  label: (m) => m == _PriceMode.unit ? l10n.whPricePerUnit(unit) : l10n.whPriceTotal,
                  onChanged: (m) => setState(() => _mode = m),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.whPriceSom,
                    hintText: l10n.commonOptional,
                    prefixIcon: const Icon(Icons.payments_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty || parseAmount(v, maxDecimals: 2) != null)
                      ? null
                      : l10n.whPriceInvalid,
                ),
                if (q > 0) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      [
                        l10n.whAfterReceipt(formatIngredientQty(ing.stock + q, ing.unit)),
                        if (unitPrice != null && totalPrice != null)
                          l10n.whPriceSummary(formatSom(unitPrice), unit, formatSom(totalPrice)),
                      ].join(' · '),
                      style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _note,
                  decoration: InputDecoration(
                    labelText: l10n.commonNote,
                    hintText: l10n.whReceiveNoteHint,
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
