import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/sales/domain/pricing/discount_limit.dart';
import 'package:bsmart/features/sales/presentation/providers/pos_cart_notifier.dart';

Product _product({double price = 50000, double? retail, double? limit}) => Product(
  id: 'p',
  name: 'p',
  price: price,
  retailPrice: retail,
  discountPercent: limit,
  currency: Currency.uzs,
  stock: 100,
  isActive: true,
);

void main() {
  group('minUnitPrice', () {
    test('no limit → null', () => expect(minUnitPrice(_product()), isNull));
    test('price less the limit', () => expect(minUnitPrice(_product(limit: 10)), 45000));
    test('a lower retail price counts', () => expect(minUnitPrice(_product(retail: 40000, limit: 10)), 40000));
  });

  group('maxLineDiscountPercent', () {
    test('at the stock price it is the limit', () => expect(maxLineDiscountPercent(_product(limit: 10), 50000), 10));
    test('no limit → null', () => expect(maxLineDiscountPercent(_product(), 50000), isNull));
    test('a retail price at or below the floor allows none', () {
      expect(maxLineDiscountPercent(_product(retail: 45000, limit: 10), 45000), 0);
    });
  });

  test('a line keeps its percent within the limit', () {
    final line = PosCartLine(product: _product(limit: 10), quantity: 2, discountPercent: 25);
    expect(line.percentFor(specialCustomer: false), 10);
    expect(line.discountFor(specialCustomer: false), 10000);
    expect(line.totalFor(specialCustomer: false), 90000);
  });

  test('the sale discount is capped by each limited line\'s room', () {
    final lines = [
      LimitLine(product: _product(limit: 10), quantity: 1, total: 50000),
      const LimitLine(product: null, quantity: 1, total: 50000),
    ];
    // 5 000 of room on a line holding half the subtotal → 10 000 overall.
    expect(maxSaleDiscount(lines), 10000);
    expect(maxSaleDiscount([const LimitLine(product: null, quantity: 1, total: 100)]), isNull);
  });

  test('isValidDiscountPercent', () {
    expect(isValidDiscountPercent(10.25), isTrue);
    expect(isValidDiscountPercent(10.125), isFalse);
    expect(isValidDiscountPercent(101), isFalse);
    expect(isValidDiscountPercent(-1), isFalse);
  });
}
