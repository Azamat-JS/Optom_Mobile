import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/warehouse/data/models/warehouse_models.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient_movement.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';

/// Raw `/ingredients` + `/recipes` calls. Restaurant owner and admins only (a waiter may read
/// `/recipes/availability`); everything is scoped to the active branch server-side.
class WarehouseRemoteDataSource {
  WarehouseRemoteDataSource(this._dio);

  final Dio _dio;

  Future<IngredientListResult> listIngredients(IngredientQuery query) async {
    final r = await _dio.get<Map<String, dynamic>>('/ingredients', queryParameters: query.toQueryParameters());
    return ingredientListFromJson(r.data!);
  }

  Future<Ingredient> getIngredient(String id) async =>
      ingredientFromJson((await _dio.get<Map<String, dynamic>>('/ingredients/$id')).data!);

  Future<Ingredient> createIngredient(CreateIngredientParams p) async =>
      ingredientFromJson((await _dio.post<Map<String, dynamic>>('/ingredients', data: p.toRequestBody())).data!);

  Future<Ingredient> updateIngredient(String id, UpdateIngredientParams p) async =>
      ingredientFromJson((await _dio.patch<Map<String, dynamic>>('/ingredients/$id', data: p.toRequestBody())).data!);

  Future<void> deleteIngredient(String id) => _dio.delete<void>('/ingredients/$id');

  Future<Ingredient> receive(String id, ReceiveIngredientParams p) async => ingredientFromJson(
    (await _dio.post<Map<String, dynamic>>('/ingredients/$id/receive', data: p.toRequestBody())).data!,
  );

  Future<Ingredient> adjust(String id, AdjustIngredientParams p) async => ingredientFromJson(
    (await _dio.post<Map<String, dynamic>>('/ingredients/$id/adjust', data: p.toRequestBody())).data!,
  );

  Future<PaginatedResult<IngredientMovement>> movements(String id, {int page = 1, int limit = 30}) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/ingredients/$id/movements',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedResult.fromJson(r.data!, movementFromJson);
  }

  Future<MenuListResult> menu(MenuQuery query) async {
    final r = await _dio.get<Map<String, dynamic>>('/recipes/menu', queryParameters: query.toQueryParameters());
    return menuListFromJson(r.data!);
  }

  Future<RecipeDetail> getRecipe(String productId) async =>
      recipeFromJson((await _dio.get<Map<String, dynamic>>('/recipes/$productId')).data!);

  Future<RecipeDetail> saveRecipe(String productId, SaveRecipeParams p) async =>
      recipeFromJson((await _dio.put<Map<String, dynamic>>('/recipes/$productId', data: p.toRequestBody())).data!);

  Future<void> deleteRecipe(String productId) => _dio.delete<void>('/recipes/$productId');

  Future<Map<String, DishAvailabilityEntry>> availability() async =>
      availabilityMapFromJson((await _dio.get<Map<String, dynamic>>('/recipes/availability')).data!);

  Future<WarehouseSummary> summary() async =>
      summaryFromJson((await _dio.get<Map<String, dynamic>>('/recipes/summary')).data!);
}
