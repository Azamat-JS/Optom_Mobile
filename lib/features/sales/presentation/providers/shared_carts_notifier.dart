import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';
import 'package:bsmart/features/sales/domain/usecases/list_shared_carts_usecase.dart';

/// The tenant's full parked-cart list — no pagination, matching `GET
/// /shared-cart`'s own small-working-set design (mirrors
/// `StoresListNotifier`'s exact shape).
class SharedCartsNotifier extends AsyncNotifier<List<SharedCart>> {
  @override
  Future<List<SharedCart>> build() => _fetch();

  Future<List<SharedCart>> _fetch() async {
    final result = await getIt<ListSharedCartsUseCase>().call();
    return result.fold((carts) => carts, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final sharedCartsProvider = AsyncNotifierProvider<SharedCartsNotifier, List<SharedCart>>(SharedCartsNotifier.new);
