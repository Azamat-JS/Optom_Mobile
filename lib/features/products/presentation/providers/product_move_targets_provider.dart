import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/active_store/presentation/active_store_notifier.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/products/domain/product_move_targets.dart';
import 'package:bsmart/features/products/domain/usecases/get_product_move_targets_usecase.dart';

/// The stores the Products list may send selected products to, from the
/// server (owners and admins; an admin's source is its own store). Refetched
/// when the account or the owner's active store changes. A failure or a
/// role/business that can't move products → no targets, so the action hides.
final productMoveTargetsProvider = FutureProvider<ProductMoveTargets>((ref) async {
  ref.watch(currentUserIdProvider);
  ref.watch(activeStoreNotifierProvider);
  final session = ref.watch(sessionNotifierProvider).valueOrNull?.session;
  if (session == null || !canMoveProducts(role: session.role, businessType: session.businessType)) {
    return noProductMoveTargets;
  }
  final result = await getIt<GetProductMoveTargetsUseCase>().call();
  return result.fold((targets) => targets, (_) => noProductMoveTargets);
});
