import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/sales/domain/pricing/special_pricing.dart';
import 'package:bsmart/features/sales/presentation/providers/pos_cart_notifier.dart';

Product _product(String id, {double price = 12000, double? retail}) =>
    Product(id: id, name: id, price: price, retailPrice: retail, currency: Currency.uzs, stock: 100, isActive: true);

void main() {
  group('effectiveUnitPrice', () {
    test('special customer pays the retail price', () {
      expect(effectiveUnitPrice(_product('a', retail: 10000), specialCustomer: true), 10000);
    });
    test('special customer pays the stock price when there is no retail price', () {
      expect(effectiveUnitPrice(_product('a'), specialCustomer: true), 12000);
    });
    test('a zero retail price counts as none', () {
      expect(retailPriceOf(_product('a', retail: 0)), isNull);
      expect(effectiveUnitPrice(_product('a', retail: 0), specialCustomer: true), 12000);
    });
    test('normal customer pays the stock price', () {
      expect(effectiveUnitPrice(_product('a', retail: 10000), specialCustomer: false), 12000);
    });
  });

  test('cart totals follow the customer, matching the server', () {
    final cart = PosCartState(
      lines: {
        'flour': PosCartLine(product: _product('flour', retail: 10000), quantity: 3, discount: 500),
        'sugar': PosCartLine(product: _product('sugar', price: 5000), quantity: 2),
      },
    );
    // 3 × 10 000 − 500 + 2 × 5 000
    expect(cart.subtotalFor(specialCustomer: true), 39500);
    // 3 × 12 000 − 500 + 2 × 5 000
    expect(cart.subtotalFor(specialCustomer: false), 45500);
    expect(cart.subtotal, 45500);
  });
}
