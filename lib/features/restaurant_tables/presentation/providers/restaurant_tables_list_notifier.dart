import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/usecases/list_restaurant_tables_usecase.dart';

/// Small working set (a restaurant has a handful of tables/rooms) — no
/// pagination, same precedent as `StoresListNotifier`/`AdminsListNotifier`.
class RestaurantTablesListNotifier extends AsyncNotifier<List<RestaurantTable>> {
  @override
  Future<List<RestaurantTable>> build() => _fetch();

  Future<List<RestaurantTable>> _fetch() async {
    final result = await getIt<ListRestaurantTablesUseCase>().call();
    return result.fold((tables) => tables, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final restaurantTablesListProvider =
    AsyncNotifierProvider<RestaurantTablesListNotifier, List<RestaurantTable>>(
  RestaurantTablesListNotifier.new,
);
