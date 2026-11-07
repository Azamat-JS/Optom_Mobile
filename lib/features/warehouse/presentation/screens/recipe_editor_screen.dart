import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/ingredient_unit.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/usecases/delete_recipe_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/get_recipe_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/list_ingredients_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/save_recipe_usecase.dart';
import 'package:bsmart/features/warehouse/domain/warehouse_math.dart';
import 'package:bsmart/features/warehouse/presentation/widgets/warehouse_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

class _Line {
  _Line({this.ingredient, String quantity = '', required this.unit}) : quantity = TextEditingController(text: quantity);

  final key = UniqueKey();
  Ingredient? ingredient;
  final TextEditingController quantity;
  IngredientUnit unit;
}

/// One portion of a dish: which ingredients and how much of each. A live preview shows how many
/// portions the current stock covers, which ingredient runs out first, and what a portion costs
/// against the menu price. The server recomputes all of it on save.
class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({required this.productId, required this.dishName, super.key});

  final String productId;
  final String dishName;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  RecipeDetail? _recipe;
  List<Ingredient> _ingredients = const [];
  final List<_Line> _lines = [];
  final _notes = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final l in _lines) {
      l.quantity.dispose();
    }
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final results = await Future.wait([
      getIt<GetRecipeUseCase>().call(widget.productId),
      getIt<ListIngredientsUseCase>().call(const IngredientQuery(limit: 500)),
    ]);
    if (!mounted) return;
    final recipeResult = results[0] as Result<RecipeDetail>;
    final listResult = results[1] as Result<IngredientListResult>;
    final failure = recipeResult.fold((_) => null, (f) => f) ?? listResult.fold((_) => null, (f) => f);
    if (failure != null) {
      setState(() {
        _loading = false;
        _loadError = warehouseErrorText(context, failure);
      });
      return;
    }
    final recipe = recipeResult.fold((r) => r, (_) => null)!;
    final ingredients = listResult.fold((r) => r.items, (_) => const <Ingredient>[]);
    final byId = {for (final i in ingredients) i.id: i};
    for (final l in _lines) {
      l.quantity.dispose();
    }
    _lines
      ..clear()
      ..addAll([
        for (final line in recipe.lines)
          _Line(ingredient: byId[line.ingredientId], quantity: _plain(line.quantity), unit: line.unit),
      ]);
    if (_lines.isEmpty) _lines.add(_Line(unit: IngredientUnit.gram));
    for (final l in _lines) {
      l.quantity.addListener(_onChanged);
    }
    setState(() {
      _recipe = recipe;
      _ingredients = ingredients;
      _notes.text = recipe.notes ?? '';
      _loading = false;
    });
  }

  void _onChanged() => setState(() {});

  static String _plain(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString().replaceAll('.', ',');

  void _addLine() {
    final line = _Line(unit: IngredientUnit.gram)..quantity.addListener(_onChanged);
    setState(() => _lines.add(line));
  }

  void _removeLine(_Line line) {
    if (_lines.length == 1) return;
    setState(() => _lines.remove(line));
    // Its field is still mounted until this frame is built; dispose the controller after it.
    WidgetsBinding.instance.addPostFrameCallback((_) => line.quantity.dispose());
  }

  Future<void> _pickIngredient(_Line line) async {
    final used = {
      for (final l in _lines)
        if (l != line && l.ingredient != null) l.ingredient!.id,
    };
    final picked = await showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: BrandColors.of(context).sheet,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _IngredientPickerSheet(ingredients: _ingredients, disabledIds: used),
    );
    if (picked == null) return;
    setState(() {
      line.ingredient = picked;
      // Keep a compatible unit; default to the natural portion unit (g for kg, ml for l).
      if (!compatibleUnits(picked.unit).contains(line.unit)) line.unit = portionUnitFor(picked.unit);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final l10n = context.l10n;
    final filled = _lines.where((l) => l.ingredient != null || l.quantity.text.trim().isNotEmpty).toList();
    String? problem;
    if (filled.isEmpty) problem = l10n.whRecipeNeedOne;
    for (final l in filled) {
      if (problem != null) break;
      if (l.ingredient == null) {
        problem = l10n.whPickIngredient;
      } else if ((parseAmount(l.quantity.text) ?? 0) <= 0) {
        problem = l10n.whRecipeBadQty(l.ingredient!.name);
      }
    }
    if (problem != null) {
      setState(() => _error = problem);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(problem)));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await getIt<SaveRecipeUseCase>().call(
      widget.productId,
      SaveRecipeParams(
        lines: [
          for (final l in filled)
            RecipeLineParams(ingredientId: l.ingredient!.id, quantity: parseAmount(l.quantity.text)!, unit: l.unit),
        ],
        notes: _notes.text.trim(),
      ),
    );
    if (!mounted) return;
    result.fold(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.whRecipeSaved)));
        Navigator.of(context).pop(true);
      },
      (failure) => setState(() {
        _saving = false;
        _error = failure.message;
      }),
    );
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.whRecipeDeleteTitle),
        content: Text(l10n.whRecipeDeleteConfirm(widget.dishName)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    final result = await getIt<DeleteRecipeUseCase>().call(widget.productId);
    if (!mounted) return;
    result.fold(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.whRecipeDeleted)));
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
    final recipe = _recipe;
    return DashPage(
      title: l10n.whRecipeTitle(widget.dishName),
      actions: [
        if (recipe?.dish.hasRecipe ?? false)
          DashRoundButton(
            icon: Icons.delete_outline_rounded,
            tooltip: l10n.whRecipeDelete,
            onTap: _saving ? null : _delete,
          ),
      ],
      bottomBar: recipe == null
          ? null
          : DashBottomButton(label: l10n.commonSave, busy: _saving, onPressed: _ingredients.isEmpty ? null : _save),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? DashEmptyState(
              icon: Icons.cloud_off_rounded,
              text: _loadError!,
              action: TextButton(onPressed: _load, child: Text(l10n.commonRetry)),
            )
          : _body(context, recipe!),
    );
  }

  Widget _body(BuildContext context, RecipeDetail recipe) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final preview = _preview();
    return DashFormTheme(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(
              l10n.whRecipeHint,
              style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          if (_ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DashCard(
                outlineColor: warehouseAmber,
                child: Text(
                  l10n.whRecipeNoIngredients,
                  style: const TextStyle(color: warehouseAmber, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          for (final (i, line) in _lines.indexed) ...[
            _LineCard(
              key: line.key,
              index: i,
              line: line,
              limiting: preview.limitingId != null && preview.limitingId == line.ingredient?.id && _lines.length > 1,
              canRemove: _lines.length > 1,
              onPick: () => _pickIngredient(line),
              onUnit: (u) => setState(() => line.unit = u),
              onRemove: () => _removeLine(line),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            onPressed: _ingredients.isEmpty ? null : _addLine,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.whAddLine),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notes,
            maxLines: 2,
            maxLength: 1000,
            decoration: InputDecoration(
              labelText: l10n.whRecipeNotes,
              hintText: l10n.commonOptional,
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 4),
          _PreviewCard(preview: preview, price: recipe.dish.price),
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
    );
  }

  _Preview _preview() {
    final valid = <({Ingredient ing, double need, int canMake})>[];
    for (final l in _lines) {
      final q = parseAmount(l.quantity.text);
      final ing = l.ingredient;
      if (ing == null || q == null || q <= 0) continue;
      final need = convertQty(q, l.unit, ing.unit);
      valid.add((ing: ing, need: need, canMake: portionsFrom(ing.stock, need)));
    }
    if (valid.isEmpty) return const _Preview();
    final limiting = valid.reduce((a, b) => b.canMake < a.canMake ? b : a);
    final cost = valid.every((v) => v.ing.avgCost != null)
        ? valid.fold<double>(0, (sum, v) => sum + v.need * v.ing.avgCost!)
        : null;
    final portions = limiting.canMake;
    final status = portions == 0 ? DishStatus.unavailable : (portions < lowPortions ? DishStatus.low : DishStatus.ok);
    return _Preview(portions: portions, limitingId: limiting.ing.id, cost: cost, status: status);
  }
}

class _Preview {
  const _Preview({this.portions, this.limitingId, this.cost, this.status});

  final int? portions;
  final String? limitingId;
  final double? cost;
  final DishStatus? status;
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.index,
    required this.line,
    required this.limiting,
    required this.canRemove,
    required this.onPick,
    required this.onUnit,
    required this.onRemove,
    super.key,
  });

  final int index;
  final _Line line;
  final bool limiting;
  final bool canRemove;
  final VoidCallback onPick;
  final ValueChanged<IngredientUnit> onUnit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final ing = line.ingredient;
    final units = ing == null ? const [IngredientUnit.gram] : compatibleUnits(ing.unit);
    final q = parseAmount(line.quantity.text);
    final need = ing == null || q == null || q <= 0 ? null : convertQty(q, line.unit, ing.unit);
    final canMake = need == null ? null : portionsFrom(ing!.stock, need);
    final error = Theme.of(context).colorScheme.error;
    return DashCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 12),
      child: DashFormTheme(
        onSheet: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.whLineN(index + 1),
                    style: TextStyle(color: colors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: l10n.whRemoveLine,
                  onPressed: canRemove ? onRemove : null,
                  icon: Icon(
                    Icons.close_rounded,
                    color: canRemove ? colors.textMuted : colors.textMuted.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(18),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.whIngredient,
                    prefixIcon: const Icon(Icons.kitchen_rounded),
                    suffixIcon: const Icon(Icons.expand_more_rounded),
                  ),
                  child: Text(
                    ing == null ? l10n.whPickIngredient : '${ing.name} · ${formatIngredientQty(ing.stock, ing.unit)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ing == null ? colors.textMuted : colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: line.quantity,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.whPerPortionAmount,
                        errorText: line.quantity.text.trim().isNotEmpty && q == null ? l10n.whAmountInvalid : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final u in units)
                        ChoiceChip(
                          label: Text(u.shortLabel),
                          selected: u == line.unit,
                          selectedColor: AppColors.brandYellow,
                          labelStyle: TextStyle(
                            color: u == line.unit ? AppColors.onBrand : colors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                          onSelected: ing == null ? null : (_) => onUnit(u),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (ing != null && need != null && canMake != null) ...[
              const SizedBox(height: 8),
              Text(
                [
                  l10n.whLineStock(formatIngredientQty(ing.stock, ing.unit), formatIngredientQty(need, ing.unit)),
                  l10n.whLinePortions(canMake),
                  if (limiting) l10n.whLimiting,
                ].join(' · '),
                style: TextStyle(
                  color: canMake == 0 ? error : (limiting ? warehouseAmber : colors.textSecondary),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (ing != null && !ing.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l10n.commonInactive, style: TextStyle(color: colors.textMuted, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview, required this.price});

  final _Preview preview;
  final double price;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cost = preview.cost;
    final margin = cost != null && price > 0 ? (price - cost) / price * 100 : null;
    return DashCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.whCanMakeNow,
                    style: TextStyle(
                      color: BrandColors.of(context).textSecondary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (preview.status != null)
                  DishAvailabilityTag(status: preview.status!, portions: preview.portions)
                else
                  const Text('—'),
              ],
            ),
          ),
          DashInfoRow(label: l10n.whPortionCost, value: cost == null ? l10n.whCostUnknown : formatSom(cost)),
          DashInfoRow(label: l10n.whMenuPrice, value: CurrencyFormatter.format(price, Currency.uzs)),
          if (margin != null)
            DashInfoRow(label: l10n.whMargin, value: '${formatSom(price - cost!)} (${margin.round()}%)'),
        ],
      ),
    );
  }
}

class _IngredientPickerSheet extends StatefulWidget {
  const _IngredientPickerSheet({required this.ingredients, required this.disabledIds});

  final List<Ingredient> ingredients;
  final Set<String> disabledIds;

  @override
  State<_IngredientPickerSheet> createState() => _IngredientPickerSheetState();
}

class _IngredientPickerSheetState extends State<_IngredientPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final q = _search.trim().toLowerCase();
    final shown = [
      for (final i in widget.ingredients)
        if (q.isEmpty || i.name.toLowerCase().contains(q)) i,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.whPickIngredient,
                  style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DashFormTheme(
                onSheet: true,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.whSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: shown.isEmpty
                  ? Center(
                      child: Text(l10n.commonNothingFound, style: TextStyle(color: colors.textMuted)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: shown.length,
                      itemBuilder: (context, i) {
                        final ing = shown[i];
                        final disabled = widget.disabledIds.contains(ing.id);
                        return ListTile(
                          enabled: !disabled,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          leading: Icon(Icons.kitchen_rounded, color: levelColor(context, ing.level)),
                          title: Text(ing.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(disabled ? l10n.whAlreadyInRecipe : formatIngredientQty(ing.stock, ing.unit)),
                          trailing: ing.isActive
                              ? null
                              : Text(l10n.commonInactive, style: TextStyle(color: colors.textMuted)),
                          onTap: () => Navigator.of(context).pop(ing),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
