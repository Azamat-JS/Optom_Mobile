import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/usecases/list_open_restaurant_orders_usecase.dart';

/// Every non-terminal order, no pagination — the order board's (and, for a
/// courier, the delivery-claim screen's) single data source, matching the
/// backend's own `findOpen()` design for a small working set.
class OpenRestaurantOrdersNotifier extends AsyncNotifier<List<RestaurantOrder>> {
  @override
  Future<List<RestaurantOrder>> build() => _fetch();

  Future<List<RestaurantOrder>> _fetch() async {
    final result = await getIt<ListOpenRestaurantOrdersUseCase>().call();
    return result.fold((orders) => orders, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final openRestaurantOrdersProvider = AsyncNotifierProvider<OpenRestaurantOrdersNotifier, List<RestaurantOrder>>(
  OpenRestaurantOrdersNotifier.new,
);
