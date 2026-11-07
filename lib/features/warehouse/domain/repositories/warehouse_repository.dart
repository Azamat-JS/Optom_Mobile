import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient_movement.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';

abstract class WarehouseRepository {
  Future<Result<IngredientListResult>> listIngredients(IngredientQuery query);
  Future<Result<Ingredient>> getIngredient(String id);
  Future<Result<Ingredient>> createIngredient(CreateIngredientParams params);
  Future<Result<Ingredient>> updateIngredient(String id, UpdateIngredientParams params);
  Future<Result<void>> deleteIngredient(String id);
  Future<Result<Ingredient>> receive(String id, ReceiveIngredientParams params);
  Future<Result<Ingredient>> adjust(String id, AdjustIngredientParams params);
  Future<Result<PaginatedResult<IngredientMovement>>> movements(String id, {int page = 1});
  Future<Result<MenuListResult>> menu(MenuQuery query);
  Future<Result<RecipeDetail>> getRecipe(String productId);
  Future<Result<RecipeDetail>> saveRecipe(String productId, SaveRecipeParams params);
  Future<Result<void>> deleteRecipe(String productId);
  Future<Result<Map<String, DishAvailabilityEntry>>> availability();
  Future<Result<WarehouseSummary>> summary();
}
