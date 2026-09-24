import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table_write_params.dart';
import 'package:bsmart/features/restaurant_tables/domain/repositories/restaurant_tables_repository.dart';

class CreateRestaurantTableUseCase {
  CreateRestaurantTableUseCase(this._repository);

  final RestaurantTablesRepository _repository;

  Future<Result<RestaurantTable>> call(CreateRestaurantTableParams params) => _repository.create(params);
}
