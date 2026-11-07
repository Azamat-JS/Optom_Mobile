import 'package:bsmart/core/enums/ingredient_unit.dart';

/// Stock against the ingredient's own minimum (computed by the server).
enum IngredientLevel {
  ok,
  low,
  out;

  static IngredientLevel fromWire(String value) => switch (value) {
    'LOW' => IngredientLevel.low,
    'OUT' => IngredientLevel.out,
    _ => IngredientLevel.ok,
  };
}

/// One recipe that uses an ingredient (ingredient detail).
class IngredientUsage {
  const IngredientUsage({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
  });

  final String productId;
  final String productName;
  final double quantity;
  final IngredientUnit unit;
}

/// A raw ingredient in a restaurant branch's warehouse ("Pomidor", "Guruch" …). [stock] may be
/// negative: the kitchen used more than was recorded (shown as a shortage, never blocks a sale).
class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.minStock,
    required this.isActive,
    required this.level,
    required this.recipeCount,
    this.avgCost,
    this.value,
    this.notes,
    this.usedIn = const [],
  });

  final String id;
  final String name;
  final IngredientUnit unit;
  final double stock;
  final double minStock;

  /// Weighted average so'm per unit; null until a receipt with a price.
  final double? avgCost;

  /// Stock × average cost (null without a cost or with nothing on hand).
  final double? value;
  final String? notes;
  final bool isActive;
  final IngredientLevel level;
  final int recipeCount;

  /// Only filled by the detail endpoint.
  final List<IngredientUsage> usedIn;
}

/// One page of the warehouse list plus the branch-wide counts the tabs show.
class IngredientListResult {
  const IngredientListResult({
    required this.items,
    required this.total,
    required this.lowCount,
    required this.outCount,
    required this.totalCount,
    required this.totalValue,
    required this.hasNext,
  });

  final List<Ingredient> items;

  /// Rows matching the current filter.
  final int total;
  final int lowCount;
  final int outCount;
  final int totalCount;
  final double totalValue;
  final bool hasNext;
}
