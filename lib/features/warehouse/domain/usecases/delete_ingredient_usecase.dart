import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class DeleteIngredientUseCase {
  DeleteIngredientUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteIngredient(id);
}
