import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table_write_params.dart';

abstract class RestaurantTablesRepository {
  Future<Result<List<RestaurantTable>>> list({String? search});

  Future<Result<RestaurantTable>> create(CreateRestaurantTableParams params);

  Future<Result<RestaurantTable>> update(String id, UpdateRestaurantTableParams params);

  Future<Result<void>> delete(String id);
}
