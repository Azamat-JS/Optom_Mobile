import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class GetDishAvailabilityUseCase {
  GetDishAvailabilityUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<Map<String, DishAvailabilityEntry>>> call() => _repository.availability();
}
