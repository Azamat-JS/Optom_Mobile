import 'package:bsmart/core/enums/ingredient_unit.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';

/// `all` / `low` (low or out) / `out`, like the web's tabs.
enum IngredientLevelFilter { all, low, out }

class IngredientQuery {
  const IngredientQuery({this.search = '', this.level = IngredientLevelFilter.all, this.page = 1, this.limit = 50});

  final String search;
  final IngredientLevelFilter level;
  final int page;
  final int limit;

  IngredientQuery copyWith({String? search, IngredientLevelFilter? level, int? page}) =>
      IngredientQuery(search: search ?? this.search, level: level ?? this.level, page: page ?? this.page, limit: limit);

  Map<String, dynamic> toQueryParameters() => {
    if (search.trim().isNotEmpty) 'search': search.trim(),
    'level': level.name,
    // Inactive ones too, so they can be switched back on.
    'status': 'all',
    'page': page,
    'limit': limit,
  };
}

class CreateIngredientParams {
  const CreateIngredientParams({
    required this.name,
    required this.unit,
    this.minStock,
    this.notes,
    this.initialQuantity,
    this.initialUnitCost,
  });

  final String name;
  final IngredientUnit unit;
  final double? minStock;
  final String? notes;
  final double? initialQuantity;
  final double? initialUnitCost;

  Map<String, dynamic> toRequestBody() => {
    'name': name,
    'unit': unit.toWire(),
    'minStock': ?minStock,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    'initialQuantity': ?initialQuantity,
    'initialUnitCost': ?initialUnitCost,
  };
}

class UpdateIngredientParams {
  const UpdateIngredientParams({required this.name, required this.minStock, required this.isActive, this.notes});

  final String name;
  final double minStock;
  final bool isActive;

  /// null / empty clears it.
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
    'name': name,
    'minStock': minStock,
    'isActive': isActive,
    'notes': (notes?.isEmpty ?? true) ? null : notes,
  };
}

class ReceiveIngredientParams {
  const ReceiveIngredientParams({required this.quantity, this.unitCost, this.totalCost, this.note});

  final double quantity;

  /// Send one of these two (or neither: a receipt without a price).
  final double? unitCost;
  final double? totalCost;
  final String? note;

  Map<String, dynamic> toRequestBody() => {
    'quantity': quantity,
    'unitCost': ?unitCost,
    'totalCost': ?totalCost,
    if (note != null && note!.isNotEmpty) 'note': note,
  };
}

/// COUNT = set the stock to what was counted; WASTE = take this much off.
enum AdjustMode { count, waste }

class AdjustIngredientParams {
  const AdjustIngredientParams({required this.mode, required this.quantity, this.note});

  final AdjustMode mode;
  final double quantity;
  final String? note;

  Map<String, dynamic> toRequestBody() => {
    'mode': mode == AdjustMode.count ? 'COUNT' : 'WASTE',
    'quantity': quantity,
    if (note != null && note!.isNotEmpty) 'note': note,
  };
}

class RecipeLineParams {
  const RecipeLineParams({required this.ingredientId, required this.quantity, required this.unit});

  final String ingredientId;
  final double quantity;
  final IngredientUnit unit;

  Map<String, dynamic> toJson() => {'ingredientId': ingredientId, 'quantity': quantity, 'unit': unit.toWire()};
}

class SaveRecipeParams {
  const SaveRecipeParams({required this.lines, this.notes});

  final List<RecipeLineParams> lines;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
    'items': [for (final l in lines) l.toJson()],
    'notes': (notes?.isEmpty ?? true) ? null : notes,
  };
}

class MenuQuery {
  const MenuQuery({this.search = '', this.status, this.page = 1, this.limit = 50});

  final String search;

  /// null = all dishes.
  final DishStatus? status;
  final int page;
  final int limit;

  MenuQuery copyWith({String? search, DishStatus? status, bool clearStatus = false, int? page}) => MenuQuery(
    search: search ?? this.search,
    status: clearStatus ? null : (status ?? this.status),
    page: page ?? this.page,
    limit: limit,
  );

  Map<String, dynamic> toQueryParameters() => {
    if (search.trim().isNotEmpty) 'search': search.trim(),
    'status': status?.toWire() ?? 'all',
    'page': page,
    'limit': limit,
  };
}
