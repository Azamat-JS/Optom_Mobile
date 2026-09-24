import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_tables/domain/repositories/restaurant_tables_repository.dart';

class DeleteRestaurantTableUseCase {
  DeleteRestaurantTableUseCase(this._repository);

  final RestaurantTablesRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
