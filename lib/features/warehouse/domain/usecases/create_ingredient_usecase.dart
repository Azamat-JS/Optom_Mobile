import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class CreateIngredientUseCase {
  CreateIngredientUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<Ingredient>> call(CreateIngredientParams params) => _repository.createIngredient(params);
}
