import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/ingredient_unit.dart';
import 'package:bsmart/features/warehouse/data/models/warehouse_models.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient_movement.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';

// Shapes copied from real Optom_Savdo responses (Decimals arrive as strings).
void main() {
  test('ingredient list with counts and value', () {
    final r = ingredientListFromJson({
      'data': [
        {
          'id': 'i1',
          'name': 'Pomidor',
          'unit': 'KILOGRAM',
          'stock': '-0.4',
          'minStock': '0.5',
          'avgCost': '9333.3333',
          'notes': null,
          'isActive': true,
          'level': 'OUT',
          'value': null,
          'recipeCount': 1,
        },
      ],
      'meta': {
        'total': 1,
        'page': 1,
        'limit': 50,
        'totalPages': 1,
        'hasNext': false,
        'hasPrev': false,
        'counts': {'total': 4, 'low': 1, 'out': 1},
        'totalValue': '266333.33',
      },
    });
    final i = r.items.single;
    expect(i.unit, IngredientUnit.kilogram);
    expect(i.stock, -0.4);
    expect(i.avgCost, closeTo(9333.3333, 1e-9));
    expect(i.level, IngredientLevel.out);
    expect(i.value, isNull);
    expect((r.totalCount, r.lowCount, r.outCount, r.totalValue), (4, 1, 1, 266333.33));
  });

  test('ingredient detail with the recipes using it', () {
    final i = ingredientFromJson({
      'id': 'i1',
      'name': "Go'sht",
      'unit': 'KILOGRAM',
      'stock': '2.7',
      'minStock': '1',
      'avgCost': '90000',
      'isActive': true,
      'level': 'OK',
      'value': '243000',
      'recipeCount': 1,
      'usedIn': [
        {'productId': 'p1', 'productName': 'Plov', 'quantity': '150', 'unit': 'GRAM'},
      ],
    });
    expect(i.usedIn.single.productName, 'Plov');
    expect(i.usedIn.single.unit, IngredientUnit.gram);
    expect(i.value, 243000);
  });

  test('movement source text for order and sale lines', () {
    final order = movementFromJson({
      'id': 'm1',
      'type': 'USAGE',
      'quantity': '-0.3',
      'unitCost': '90000',
      'balanceAfter': '2.7',
      'note': 'RO-1',
      'reversedAt': '2026-11-07T10:00:00.000Z',
      'createdAt': '2026-11-07T09:00:00.000Z',
      'createdBy': {'id': 'u', 'firstName': 'Ali', 'lastName': 'Valiyev'},
      'restaurantOrderItem': {
        'productName': 'Plov',
        'quantity': 2,
        'order': {'id': 'o', 'orderNumber': 'RO-1'},
      },
      'saleItem': null,
    });
    expect(order.type, IngredientMovementType.usage);
    expect(order.reversed, isTrue);
    expect(order.source, 'RO-1 · Plov × 2');
    expect(order.actorName, 'Ali Valiyev');

    final sale = movementFromJson({
      'id': 'm2',
      'type': 'USAGE',
      'quantity': '-0.6',
      'unitCost': null,
      'balanceAfter': '-0.4',
      'createdAt': '2026-11-07T09:00:00.000Z',
      'createdBy': null,
      'restaurantOrderItem': null,
      'saleItem': {
        'productName': 'Salat',
        'quantity': '2',
        'sale': {'id': 's', 'saleNumber': 'SALE-1'},
      },
    });
    expect(sale.source, 'SALE-1 · Salat × 2');
    expect(sale.balanceAfter, -0.4);
  });

  test('menu list with availability and counts', () {
    final r = menuListFromJson({
      'data': [
        {
          'id': 'p1',
          'productId': 'p1',
          'name': 'Salat',
          'price': '20000',
          'isActive': true,
          'imageUrl': null,
          'category': {'id': 'c', 'name': 'Salatlar'},
          'hasRecipe': true,
          'ingredientCount': 1,
          'availability': {
            'status': 'UNAVAILABLE',
            'portions': 0,
            'limitingIngredientId': 'i1',
            'missing': [
              {
                'ingredientId': 'i1',
                'name': 'Pomidor',
                'unit': 'KILOGRAM',
                'need': '3',
                'stock': '2.5',
                'short': '0.5',
              },
            ],
            'portionCost': '28000',
          },
        },
      ],
      'meta': {
        'total': 1,
        'page': 1,
        'limit': 50,
        'totalPages': 1,
        'hasNext': false,
        'hasPrev': false,
        'counts': {'total': 3, 'OK': 1, 'LOW': 0, 'UNAVAILABLE': 1, 'NO_RECIPE': 1},
      },
    });
    final dish = r.items.single;
    expect(dish.availability.status, DishStatus.unavailable);
    expect(dish.availability.missing.single.short, 0.5);
    expect(dish.categoryName, 'Salatlar');
    expect(r.counts.of(null), 3);
    expect(r.counts.of(DishStatus.noRecipe), 1);
  });

  test('a dish without a recipe has no portions', () {
    final d = menuDishFromJson({
      'productId': 'p3',
      'name': 'Choy',
      'price': '5000',
      'hasRecipe': false,
      'ingredientCount': 0,
      'availability': {'status': 'NO_RECIPE', 'portions': null, 'missing': [], 'portionCost': null},
    });
    expect(d.availability.status, DishStatus.noRecipe);
    expect(d.availability.portions, isNull);
  });

  test('availability map and summary', () {
    final map = availabilityMapFromJson({
      'p1': {'status': 'LOW', 'portions': 3, 'missing': []},
      'p2': {
        'status': 'UNAVAILABLE',
        'portions': 0,
        'missing': ['Pomidor'],
      },
    });
    expect(map['p1']!.portions, 3);
    expect(map['p2']!.missing, ['Pomidor']);
    final s = summaryFromJson({
      'ingredients': {'total': 4, 'low': 1, 'out': 2},
      'dishes': {'total': 3, 'unavailable': 1, 'low': 0, 'noRecipe': 1},
    });
    expect((s.ingredientsLow, s.ingredientsOut, s.dishesUnavailable), (1, 2, 1));
  });

  test('request bodies match the server DTOs', () {
    expect(
      const CreateIngredientParams(
        name: 'Guruch',
        unit: IngredientUnit.kilogram,
        initialQuantity: 10,
        initialUnitCost: 12000,
      ).toRequestBody(),
      {'name': 'Guruch', 'unit': 'KILOGRAM', 'initialQuantity': 10.0, 'initialUnitCost': 12000.0},
    );
    expect(const ReceiveIngredientParams(quantity: 2, totalCost: 20000).toRequestBody(), {
      'quantity': 2.0,
      'totalCost': 20000.0,
    });
    expect(const AdjustIngredientParams(mode: AdjustMode.waste, quantity: 0.5).toRequestBody(), {
      'mode': 'WASTE',
      'quantity': 0.5,
    });
    expect(
      const SaveRecipeParams(
        lines: [RecipeLineParams(ingredientId: 'i', quantity: 150, unit: IngredientUnit.gram)],
      ).toRequestBody(),
      {
        'items': [
          {'ingredientId': 'i', 'quantity': 150.0, 'unit': 'GRAM'},
        ],
        'notes': null,
      },
    );
    expect(const MenuQuery(status: DishStatus.unavailable).toQueryParameters()['status'], 'UNAVAILABLE');
    expect(const IngredientQuery(level: IngredientLevelFilter.low).toQueryParameters()['level'], 'low');
  });
}
