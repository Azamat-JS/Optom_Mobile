import 'package:bsmart/core/l10n/app_l10n.dart';

/// Mirrors the backend's Prisma `IngredientUnit` enum exactly (restaurant
/// warehouse, see Optom_Savdo `CLAUDE.md` "Restaurant Warehouse & Recipes").
enum IngredientUnit {
  kilogram,
  gram,
  litr,
  millilitr,
  dona;

  static IngredientUnit fromWire(String value) => switch (value) {
    'KILOGRAM' => IngredientUnit.kilogram,
    'GRAM' => IngredientUnit.gram,
    'LITR' => IngredientUnit.litr,
    'MILLILITR' => IngredientUnit.millilitr,
    'DONA' => IngredientUnit.dona,
    _ => throw ArgumentError('Unknown IngredientUnit from backend: $value'),
  };

  String toWire() => switch (this) {
    IngredientUnit.kilogram => 'KILOGRAM',
    IngredientUnit.gram => 'GRAM',
    IngredientUnit.litr => 'LITR',
    IngredientUnit.millilitr => 'MILLILITR',
    IngredientUnit.dona => 'DONA',
  };

  /// "Kilogramm (kg)".
  String get label => appL10n.enumIngredientUnit(name);

  /// "kg", "g", "l", "ml", "dona".
  String get shortLabel => appL10n.enumIngredientUnitShort(name);

  /// mass / volume / count — a recipe line may use any unit of the same dimension.
  String get dimension => switch (this) {
    IngredientUnit.kilogram || IngredientUnit.gram => 'mass',
    IngredientUnit.litr || IngredientUnit.millilitr => 'volume',
    IngredientUnit.dona => 'count',
  };

  /// How many base units (g, ml, piece) one of this is.
  double get toBase => switch (this) {
    IngredientUnit.kilogram || IngredientUnit.litr => 1000,
    _ => 1,
  };

  bool get isCount => this == IngredientUnit.dona;
}
