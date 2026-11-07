import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class GetIngredientUseCase {
  GetIngredientUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<Ingredient>> call(String id) => _repository.getIngredient(id);
}
