import 'package:bsmart/core/enums/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every UserRole round-trips through the backend wire format', () {
    for (final role in UserRole.values) {
      expect(UserRole.fromWire(role.toWire()), role);
    }
  });

  test('admin roles inherit their owner family, WAITER/COURIER do not', () {
    expect(UserRole.sellerAdmin.isSellerFamily, isTrue);
    expect(UserRole.retailerAdmin.isRetailerFamily, isTrue);
    expect(UserRole.waiter.isSellerFamily || UserRole.waiter.isRetailerFamily, isFalse);
    expect(UserRole.courier.isStaff, isFalse);
    expect(UserRole.sellerAdmin.isStaff, isTrue);
  });
}
