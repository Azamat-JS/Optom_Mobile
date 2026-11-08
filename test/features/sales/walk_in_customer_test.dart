import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/features/sales/domain/entities/sale.dart';

void main() {
  test('the walk-in sentinel customer is recognised', () {
    const walkIn = SalePersonRef(id: 'w', firstName: 'Mehmon', lastName: 'xaridor', phone: walkInCustomerPhone);
    expect(walkIn.isWalkIn, isTrue);
  });

  test('a real customer, or a renamed walk-in row, is not', () {
    const real = SalePersonRef(id: 'c', firstName: 'Jasur', lastName: 'Karimov', phone: '+998901112233');
    const renamed = SalePersonRef(id: 'w', firstName: 'Ali', lastName: 'xaridor', phone: walkInCustomerPhone);
    const samePhoneOnly = SalePersonRef(id: 'x', firstName: 'Mehmon', lastName: 'xaridor', phone: '+998900000000');
    expect(real.isWalkIn, isFalse);
    expect(renamed.isWalkIn, isFalse);
    expect(samePhoneOnly.isWalkIn, isFalse);
  });
}
