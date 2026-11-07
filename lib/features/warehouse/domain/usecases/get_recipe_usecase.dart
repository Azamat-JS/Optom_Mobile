import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class GetRecipeUseCase {
  GetRecipeUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<RecipeDetail>> call(String productId) => _repository.getRecipe(productId);
}
