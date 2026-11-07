import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class SaveRecipeUseCase {
  SaveRecipeUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<RecipeDetail>> call(String productId, SaveRecipeParams params) =>
      _repository.saveRecipe(productId, params);
}
