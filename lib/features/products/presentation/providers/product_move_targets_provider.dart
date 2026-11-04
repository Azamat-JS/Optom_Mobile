import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/active_store/presentation/active_store_notifier.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/products/domain/product_move_targets.dart';
import 'package:bsmart/features/stores/presentation/providers/stores_list_notifier.dart';

/// The stores the Products list may send selected products to; empty hides the
/// action. Staff never watch the store roster (`GET /stores` is owner-only).
final productMoveTargetsProvider = Provider<ProductMoveTargets>((ref) {
  final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
  if (session == null || session.isStaff) return noProductMoveTargets;
  if (session.role != UserRole.seller && session.role != UserRole.retailer) return noProductMoveTargets;

  final stores = ref.watch(storesListProvider).valueOrNull;
  if (stores == null) return noProductMoveTargets;
  return productMoveTargets(
    role: session.role,
    isStaff: session.isStaff,
    businessType: session.businessType,
    stores: stores,
    activeStoreId: ref.watch(activeStoreNotifierProvider).valueOrNull,
  );
});
