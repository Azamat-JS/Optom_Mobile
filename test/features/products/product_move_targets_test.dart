import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/products/domain/product_move_targets.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';

Store _store(String id, {bool isDefault = false, bool isActive = true}) =>
    Store(id: id, name: id, isActive: isActive, isDefault: isDefault, createdAt: DateTime(2026));

void main() {
  final stores = [_store('main', isDefault: true), _store('branch'), _store('closed', isActive: false), _store('third')];

  ProductMoveTargets run({
    UserRole role = UserRole.retailer,
    bool isStaff = false,
    BusinessType? businessType = BusinessType.general,
    List<Store>? list,
    String? active = 'main',
  }) => productMoveTargets(
    role: role,
    isStaff: isStaff,
    businessType: businessType,
    stores: list ?? stores,
    activeStoreId: active,
  );

  List<String> ids(ProductMoveTargets t) => t.targets.map((s) => s.id).toList();

  test('owner: the other active stores', () {
    final t = run();
    expect(t.source?.id, 'main');
    expect(ids(t), ['branch', 'third']);
  });

  test('wholesaler owner too', () => expect(ids(run(role: UserRole.seller, businessType: null)), ['branch', 'third']));

  test('from a branch, the main store is a target', () => expect(ids(run(active: 'branch')), ['main', 'third']));

  test('no saved store → the default store is the source', () {
    final t = run(active: null);
    expect(t.source?.id, 'main');
    expect(ids(t), ['branch', 'third']);
  });

  test('a saved store that no longer exists → default store', () => expect(run(active: 'gone').source?.id, 'main'));

  test('no default store → the first one', () {
    expect(run(list: [_store('a'), _store('b')], active: null).source?.id, 'a');
  });

  test('admins and other staff get nothing', () {
    expect(run(role: UserRole.retailerAdmin, isStaff: true).targets, isEmpty);
    expect(run(role: UserRole.sellerAdmin, isStaff: true).targets, isEmpty);
    expect(run(role: UserRole.waiter, isStaff: true).targets, isEmpty);
  });

  test('a restaurant owner gets nothing', () => expect(run(businessType: BusinessType.restaurant).targets, isEmpty));

  test('single store, or only inactive others → nothing', () {
    expect(run(list: [_store('main', isDefault: true)]).targets, isEmpty);
    expect(run(list: [_store('main', isDefault: true), _store('x', isActive: false)]).targets, isEmpty);
    expect(run(list: const []).targets, isEmpty);
  });
}
