import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class DeleteRecipeUseCase {
  DeleteRecipeUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<void>> call(String productId) => _repository.deleteRecipe(productId);
}
