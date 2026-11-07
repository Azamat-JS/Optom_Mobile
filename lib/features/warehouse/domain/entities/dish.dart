import 'package:bsmart/core/enums/ingredient_unit.dart';

/// Whether the warehouse can make a dish right now.
enum DishStatus {
  ok,
  low,
  unavailable,
  noRecipe;

  static DishStatus fromWire(String value) => switch (value) {
    'LOW' => DishStatus.low,
    'UNAVAILABLE' => DishStatus.unavailable,
    'NO_RECIPE' => DishStatus.noRecipe,
    _ => DishStatus.ok,
  };

  String toWire() => switch (this) {
    DishStatus.ok => 'OK',
    DishStatus.low => 'LOW',
    DishStatus.unavailable => 'UNAVAILABLE',
    DishStatus.noRecipe => 'NO_RECIPE',
  };
}

/// An ingredient that doesn't cover one portion, and how much is missing for one.
class MissingIngredient {
  const MissingIngredient({
    required this.ingredientId,
    required this.name,
    required this.unit,
    required this.need,
    required this.stock,
    required this.short,
  });

  final String ingredientId;
  final String name;
  final IngredientUnit unit;
  final double need;
  final double stock;
  final double short;
}

/// Computed live by the server from the ingredients' current stock.
class DishAvailability {
  const DishAvailability({
    required this.status,
    this.portions,
    this.limitingIngredientId,
    this.missing = const [],
    this.portionCost,
  });

  final DishStatus status;

  /// Whole portions the warehouse can make (null without a recipe).
  final int? portions;
  final String? limitingIngredientId;
  final List<MissingIngredient> missing;

  /// So'm per portion; null when an ingredient has no known cost.
  final double? portionCost;
}

/// A menu dish (a `Product`) with its recipe status.
class MenuDish {
  const MenuDish({
    required this.productId,
    required this.name,
    required this.price,
    required this.isActive,
    required this.hasRecipe,
    required this.ingredientCount,
    required this.availability,
    this.imageUrl,
    this.categoryName,
  });

  final String productId;
  final String name;
  final double price;
  final bool isActive;
  final String? imageUrl;
  final String? categoryName;
  final bool hasRecipe;
  final int ingredientCount;
  final DishAvailability availability;
}

class MenuListResult {
  const MenuListResult({required this.items, required this.counts, required this.hasNext});

  final List<MenuDish> items;

  /// Per status, plus the dish total.
  final DishStatusCounts counts;
  final bool hasNext;
}

class DishStatusCounts {
  const DishStatusCounts({
    required this.total,
    required this.ok,
    required this.low,
    required this.unavailable,
    required this.noRecipe,
  });

  final int total;
  final int ok;
  final int low;
  final int unavailable;
  final int noRecipe;

  int of(DishStatus? status) => switch (status) {
    null => total,
    DishStatus.ok => ok,
    DishStatus.low => low,
    DishStatus.unavailable => unavailable,
    DishStatus.noRecipe => noRecipe,
  };
}

/// One recipe line as saved: its own amount/unit plus the ingredient's live stock.
class RecipeLine {
  const RecipeLine({
    required this.quantity,
    required this.unit,
    required this.ingredientId,
    required this.ingredientName,
    required this.ingredientUnit,
    required this.ingredientStock,
    required this.ingredientActive,
    this.ingredientAvgCost,
  });

  final double quantity;
  final IngredientUnit unit;
  final String ingredientId;
  final String ingredientName;
  final IngredientUnit ingredientUnit;
  final double ingredientStock;
  final double? ingredientAvgCost;
  final bool ingredientActive;
}

class RecipeDetail {
  const RecipeDetail({required this.dish, required this.lines, this.notes});

  final MenuDish dish;
  final List<RecipeLine> lines;
  final String? notes;
}

/// The small per-dish form the menu screens show next to a dish.
class DishAvailabilityEntry {
  const DishAvailabilityEntry({required this.status, this.portions, this.missing = const []});

  final DishStatus status;
  final int? portions;

  /// Names of the ingredients that don't cover one portion.
  final List<String> missing;
}

/// Counts for the home-screen badges.
class WarehouseSummary {
  const WarehouseSummary({
    required this.ingredientsLow,
    required this.ingredientsOut,
    required this.dishesUnavailable,
    required this.dishesLow,
  });

  final int ingredientsLow;
  final int ingredientsOut;
  final int dishesUnavailable;
  final int dishesLow;
}
