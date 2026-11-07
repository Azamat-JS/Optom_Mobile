import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient_movement.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class ListIngredientMovementsUseCase {
  ListIngredientMovementsUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<PaginatedResult<IngredientMovement>>> call(String id, {int page = 1}) =>
      _repository.movements(id, page: page);
}
