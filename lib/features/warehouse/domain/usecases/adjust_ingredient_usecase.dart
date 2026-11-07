import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class AdjustIngredientUseCase {
  AdjustIngredientUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<Ingredient>> call(String id, AdjustIngredientParams params) => _repository.adjust(id, params);
}
