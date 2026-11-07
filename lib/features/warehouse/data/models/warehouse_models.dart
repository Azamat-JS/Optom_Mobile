import 'package:bsmart/core/enums/ingredient_unit.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient_movement.dart';

// Parsers for the `/ingredients` and `/recipes` responses (Optom_Savdo `warehouse/`). Amounts are
// Prisma Decimals, which arrive as strings; counts are plain JSON numbers.

double _num(Object? v) => v is num ? v.toDouble() : double.parse(v as String);
double? _numOrNull(Object? v) => v == null ? null : _num(v);

Ingredient ingredientFromJson(Map<String, dynamic> json) => Ingredient(
  id: json['id'] as String,
  name: json['name'] as String,
  unit: IngredientUnit.fromWire(json['unit'] as String),
  stock: _num(json['stock']),
  minStock: _num(json['minStock']),
  avgCost: _numOrNull(json['avgCost']),
  value: _numOrNull(json['value']),
  notes: json['notes'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  level: IngredientLevel.fromWire(json['level'] as String? ?? 'OK'),
  recipeCount: (json['recipeCount'] as num?)?.toInt() ?? 0,
  usedIn: [
    for (final u in (json['usedIn'] as List? ?? const []).cast<Map<String, dynamic>>())
      IngredientUsage(
        productId: u['productId'] as String,
        productName: u['productName'] as String? ?? '',
        quantity: _num(u['quantity']),
        unit: IngredientUnit.fromWire(u['unit'] as String),
      ),
  ],
);

IngredientListResult ingredientListFromJson(Map<String, dynamic> json) {
  final meta = json['meta'] as Map<String, dynamic>;
  final counts = meta['counts'] as Map<String, dynamic>? ?? const {};
  return IngredientListResult(
    items: [for (final row in (json['data'] as List).cast<Map<String, dynamic>>()) ingredientFromJson(row)],
    total: (meta['total'] as num).toInt(),
    totalCount: (counts['total'] as num?)?.toInt() ?? 0,
    lowCount: (counts['low'] as num?)?.toInt() ?? 0,
    outCount: (counts['out'] as num?)?.toInt() ?? 0,
    totalValue: _numOrNull(meta['totalValue']) ?? 0,
    hasNext: meta['hasNext'] as bool? ?? false,
  );
}

IngredientMovement movementFromJson(Map<String, dynamic> json) {
  final by = json['createdBy'] as Map<String, dynamic>?;
  final orderLine = json['restaurantOrderItem'] as Map<String, dynamic>?;
  final saleLine = json['saleItem'] as Map<String, dynamic>?;
  String? source;
  if (orderLine != null) {
    final order = orderLine['order'] as Map<String, dynamic>?;
    source = '${order?['orderNumber'] ?? ''} · ${orderLine['productName']} × ${_fmtQty(orderLine['quantity'])}';
  } else if (saleLine != null) {
    final sale = saleLine['sale'] as Map<String, dynamic>?;
    source = '${sale?['saleNumber'] ?? ''} · ${saleLine['productName']} × ${_fmtQty(saleLine['quantity'])}';
  }
  return IngredientMovement(
    id: json['id'] as String,
    type: IngredientMovementType.fromWire(json['type'] as String),
    quantity: _num(json['quantity']),
    unitCost: _numOrNull(json['unitCost']),
    balanceAfter: _num(json['balanceAfter']),
    note: json['note'] as String?,
    reversed: json['reversedAt'] != null,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    actorName: by == null ? null : '${by['firstName'] ?? ''} ${by['lastName'] ?? ''}'.trim(),
    source: source,
  );
}

String _fmtQty(Object? v) {
  final n = _num(v);
  return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
}

DishAvailability _availabilityFromJson(Map<String, dynamic> json) => DishAvailability(
  status: DishStatus.fromWire(json['status'] as String),
  portions: (json['portions'] as num?)?.toInt(),
  limitingIngredientId: json['limitingIngredientId'] as String?,
  portionCost: _numOrNull(json['portionCost']),
  missing: [
    for (final m in (json['missing'] as List? ?? const []).cast<Map<String, dynamic>>())
      MissingIngredient(
        ingredientId: m['ingredientId'] as String,
        name: m['name'] as String,
        unit: IngredientUnit.fromWire(m['unit'] as String),
        need: _num(m['need']),
        stock: _num(m['stock']),
        short: _num(m['short']),
      ),
  ],
);

MenuDish menuDishFromJson(Map<String, dynamic> json) => MenuDish(
  productId: json['productId'] as String,
  name: json['name'] as String? ?? '',
  price: _num(json['price']),
  isActive: json['isActive'] as bool? ?? true,
  imageUrl: json['imageUrl'] as String?,
  categoryName: (json['category'] as Map<String, dynamic>?)?['name'] as String?,
  hasRecipe: json['hasRecipe'] as bool? ?? false,
  ingredientCount: (json['ingredientCount'] as num?)?.toInt() ?? 0,
  availability: _availabilityFromJson(json['availability'] as Map<String, dynamic>),
);

MenuListResult menuListFromJson(Map<String, dynamic> json) {
  final meta = json['meta'] as Map<String, dynamic>;
  final c = meta['counts'] as Map<String, dynamic>? ?? const {};
  int n(String k) => (c[k] as num?)?.toInt() ?? 0;
  return MenuListResult(
    items: [for (final row in (json['data'] as List).cast<Map<String, dynamic>>()) menuDishFromJson(row)],
    counts: DishStatusCounts(
      total: n('total'),
      ok: n('OK'),
      low: n('LOW'),
      unavailable: n('UNAVAILABLE'),
      noRecipe: n('NO_RECIPE'),
    ),
    hasNext: meta['hasNext'] as bool? ?? false,
  );
}

RecipeDetail recipeFromJson(Map<String, dynamic> json) => RecipeDetail(
  dish: menuDishFromJson(json),
  notes: json['notes'] as String?,
  lines: [
    for (final row in (json['items'] as List? ?? const []).cast<Map<String, dynamic>>())
      () {
        final ing = row['ingredient'] as Map<String, dynamic>;
        return RecipeLine(
          quantity: _num(row['quantity']),
          unit: IngredientUnit.fromWire(row['unit'] as String),
          ingredientId: ing['id'] as String,
          ingredientName: ing['name'] as String,
          ingredientUnit: IngredientUnit.fromWire(ing['unit'] as String),
          ingredientStock: _num(ing['stock']),
          ingredientAvgCost: _numOrNull(ing['avgCost']),
          ingredientActive: ing['isActive'] as bool? ?? true,
        );
      }(),
  ],
);

Map<String, DishAvailabilityEntry> availabilityMapFromJson(Map<String, dynamic> json) => {
  for (final e in json.entries)
    e.key: () {
      final v = e.value as Map<String, dynamic>;
      return DishAvailabilityEntry(
        status: DishStatus.fromWire(v['status'] as String),
        portions: (v['portions'] as num?)?.toInt(),
        missing: (v['missing'] as List? ?? const []).cast<String>(),
      );
    }(),
};

WarehouseSummary summaryFromJson(Map<String, dynamic> json) {
  final ing = json['ingredients'] as Map<String, dynamic>? ?? const {};
  final dishes = json['dishes'] as Map<String, dynamic>? ?? const {};
  return WarehouseSummary(
    ingredientsLow: (ing['low'] as num?)?.toInt() ?? 0,
    ingredientsOut: (ing['out'] as num?)?.toInt() ?? 0,
    dishesUnavailable: (dishes['unavailable'] as num?)?.toInt() ?? 0,
    dishesLow: (dishes['low'] as num?)?.toInt() ?? 0,
  );
}
