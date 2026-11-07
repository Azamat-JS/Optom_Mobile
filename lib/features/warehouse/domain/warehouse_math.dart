import 'package:bsmart/core/enums/ingredient_unit.dart';

// Mirror of the server's `warehouse/recipe-math.ts` unit rules, for live previews only (the
// recipe editor's "N portions", cost and margin). The server recomputes and stores everything.

/// A dish with fewer portions than this left is "running low" (same threshold as the server).
const lowPortions = 5;

/// Units a recipe line may use for an ingredient kept in [unit] (kg → kg or g …).
List<IngredientUnit> compatibleUnits(IngredientUnit unit) => [
  for (final u in IngredientUnit.values)
    if (u.dimension == unit.dimension) u,
];

/// The natural unit to type one portion in: grams for a kg ingredient, ml for litres.
IngredientUnit portionUnitFor(IngredientUnit unit) => switch (unit) {
  IngredientUnit.kilogram => IngredientUnit.gram,
  IngredientUnit.litr => IngredientUnit.millilitr,
  _ => unit,
};

/// 150 g → 0.15 kg. Both units must be of the same dimension.
double convertQty(double quantity, IngredientUnit from, IngredientUnit to) {
  if (from.dimension != to.dimension) throw ArgumentError('Cannot convert $from to $to');
  return quantity * from.toBase / to.toBase;
}

/// Whole portions [stock] covers when one portion needs [need] (same unit). Negative stock is
/// nothing on hand. The epsilon matches the server's exact decimal division (0.3 / 0.1 is 3).
int portionsFrom(double stock, double need) {
  if (need <= 0) return 1 << 30;
  if (stock <= 0) return 0;
  return (stock / need + 1e-9).floor();
}

/// Parses a typed amount: spaces allowed, comma or dot decimals, at most [maxDecimals] digits
/// after it. Returns null for anything else (empty included).
double? parseAmount(String text, {int maxDecimals = 4}) {
  final s = text.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(s)) return null;
  final dot = s.indexOf('.');
  if (dot >= 0 && s.length - dot - 1 > maxDecimals) return null;
  return double.parse(s);
}
