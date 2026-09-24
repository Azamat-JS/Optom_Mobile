import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/repositories/restaurant_tables_repository.dart';

class ListRestaurantTablesUseCase {
  ListRestaurantTablesUseCase(this._repository);

  final RestaurantTablesRepository _repository;

  Future<Result<List<RestaurantTable>>> call({String? search}) => _repository.list(search: search);
}
