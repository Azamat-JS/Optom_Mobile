import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/repositories/warehouse_repository.dart';

class ListMenuDishesUseCase {
  ListMenuDishesUseCase(this._repository);

  final WarehouseRepository _repository;

  Future<Result<MenuListResult>> call(MenuQuery query) => _repository.menu(query);
}
