import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/data/datasources/warehouse_remote_data_source.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient_movement.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  WarehouseRepositoryImpl(this._remote);

  final WarehouseRemoteDataSource _remote;

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.ok(await call());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<IngredientListResult>> listIngredients(IngredientQuery query) =>
      _guard(() => _remote.listIngredients(query));

  @override
  Future<Result<Ingredient>> getIngredient(String id) => _guard(() => _remote.getIngredient(id));

  @override
  Future<Result<Ingredient>> createIngredient(CreateIngredientParams params) =>
      _guard(() => _remote.createIngredient(params));

  @override
  Future<Result<Ingredient>> updateIngredient(String id, UpdateIngredientParams params) =>
      _guard(() => _remote.updateIngredient(id, params));

  @override
  Future<Result<void>> deleteIngredient(String id) => _guard(() => _remote.deleteIngredient(id));

  @override
  Future<Result<Ingredient>> receive(String id, ReceiveIngredientParams params) =>
      _guard(() => _remote.receive(id, params));

  @override
  Future<Result<Ingredient>> adjust(String id, AdjustIngredientParams params) =>
      _guard(() => _remote.adjust(id, params));

  @override
  Future<Result<PaginatedResult<IngredientMovement>>> movements(String id, {int page = 1}) =>
      _guard(() => _remote.movements(id, page: page));

  @override
  Future<Result<MenuListResult>> menu(MenuQuery query) => _guard(() => _remote.menu(query));

  @override
  Future<Result<RecipeDetail>> getRecipe(String productId) => _guard(() => _remote.getRecipe(productId));

  @override
  Future<Result<RecipeDetail>> saveRecipe(String productId, SaveRecipeParams params) =>
      _guard(() => _remote.saveRecipe(productId, params));

  @override
  Future<Result<void>> deleteRecipe(String productId) => _guard(() => _remote.deleteRecipe(productId));

  @override
  Future<Result<Map<String, DishAvailabilityEntry>>> availability() => _guard(_remote.availability);

  @override
  Future<Result<WarehouseSummary>> summary() => _guard(_remote.summary);
}
