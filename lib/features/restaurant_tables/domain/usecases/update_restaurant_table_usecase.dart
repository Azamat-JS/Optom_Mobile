import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table_write_params.dart';
import 'package:bsmart/features/restaurant_tables/domain/repositories/restaurant_tables_repository.dart';

class UpdateRestaurantTableUseCase {
  UpdateRestaurantTableUseCase(this._repository);

  final RestaurantTablesRepository _repository;

  Future<Result<RestaurantTable>> call(String id, UpdateRestaurantTableParams params) =>
      _repository.update(id, params);
}
