import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/ingredient_unit.dart';
import 'package:bsmart/features/warehouse/domain/warehouse_math.dart';

void main() {
  group('units', () {
    test('converts within a dimension', () {
      expect(convertQty(150, IngredientUnit.gram, IngredientUnit.kilogram), closeTo(0.15, 1e-12));
      expect(convertQty(0.25, IngredientUnit.litr, IngredientUnit.millilitr), 250);
      expect(convertQty(3, IngredientUnit.dona, IngredientUnit.dona), 3);
    });

    test('refuses mixing dimensions', () {
      expect(() => convertQty(1, IngredientUnit.gram, IngredientUnit.litr), throwsArgumentError);
      expect(() => convertQty(1, IngredientUnit.dona, IngredientUnit.kilogram), throwsArgumentError);
    });

    test('compatible units and the natural portion unit', () {
      expect(compatibleUnits(IngredientUnit.kilogram), [IngredientUnit.kilogram, IngredientUnit.gram]);
      expect(compatibleUnits(IngredientUnit.dona), [IngredientUnit.dona]);
      expect(portionUnitFor(IngredientUnit.kilogram), IngredientUnit.gram);
      expect(portionUnitFor(IngredientUnit.litr), IngredientUnit.millilitr);
      expect(portionUnitFor(IngredientUnit.dona), IngredientUnit.dona);
    });
  });

  group('portionsFrom', () {
    test('whole portions, exact on boundaries', () {
      expect(portionsFrom(1, 0.15), 6);
      expect(portionsFrom(0.3, 0.1), 3); // float division gives 2.9999…
      expect(portionsFrom(3, 0.15), 20);
    });

    test('nothing or negative stock makes nothing', () {
      expect(portionsFrom(0, 0.1), 0);
      expect(portionsFrom(-2, 0.1), 0);
      expect(portionsFrom(0.05, 0.1), 0);
    });
  });

  group('parseAmount', () {
    test('accepts comma, dot and spaces', () {
      expect(parseAmount('2,5'), 2.5);
      expect(parseAmount('2.5'), 2.5);
      expect(parseAmount('20 000'), 20000);
      expect(parseAmount('0,0025'), 0.0025);
    });

    test('rejects junk, signs, empty and too many decimals', () {
      expect(parseAmount(''), isNull);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('-1'), isNull);
      expect(parseAmount('1,23456'), isNull);
      expect(parseAmount('1,234', maxDecimals: 2), isNull);
      expect(parseAmount('1,23', maxDecimals: 2), 1.23);
    });
  });
}
