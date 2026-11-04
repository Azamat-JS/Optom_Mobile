import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/products/domain/product_move_targets.dart';

void main() {
  group('canMoveProducts', () {
    test('owners and their admins', () {
      for (final role in [UserRole.seller, UserRole.sellerAdmin, UserRole.retailer, UserRole.retailerAdmin]) {
        expect(canMoveProducts(role: role, businessType: BusinessType.general), isTrue, reason: '$role');
      }
      expect(canMoveProducts(role: UserRole.seller, businessType: null), isTrue);
    });

    test('other staff, agents, customers and the platform admin never', () {
      for (final role in [
        UserRole.waiter,
        UserRole.courier,
        UserRole.leadAgent,
        UserRole.agent,
        UserRole.customer,
        UserRole.superAdmin,
      ]) {
        expect(canMoveProducts(role: role, businessType: BusinessType.general), isFalse, reason: '$role');
      }
    });

    test('not a restaurant, owner or admin', () {
      expect(canMoveProducts(role: UserRole.retailer, businessType: BusinessType.restaurant), isFalse);
      expect(canMoveProducts(role: UserRole.retailerAdmin, businessType: BusinessType.restaurant), isFalse);
    });
  });

  group('productMoveTargetsFromJson', () {
    test('source and targets', () {
      final t = productMoveTargetsFromJson({
        'source': {'id': 's1', 'name': 'Markaz', 'address': null, 'isDefault': true},
        'targets': [
          {'id': 's2', 'name': 'Chilonzor', 'address': 'Chilonzor 9', 'isDefault': false},
        ],
      });
      expect(t.source?.id, 's1');
      expect(t.source?.isDefault, isTrue);
      expect(t.targets.single.name, 'Chilonzor');
      expect(t.targets.single.address, 'Chilonzor 9');
    });

    test('an admin without a store → nothing', () {
      final t = productMoveTargetsFromJson({'source': null, 'targets': []});
      expect(t.source, isNull);
      expect(t.targets, isEmpty);
    });
  });
}
