import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_write_params.dart';
import 'package:bsmart/features/restaurant_orders/domain/repositories/restaurant_orders_repository.dart';

class CreateRestaurantOrderUseCase {
  CreateRestaurantOrderUseCase(this._repository);

  final RestaurantOrdersRepository _repository;

  Future<Result<RestaurantOrder>> call(CreateRestaurantOrderParams params) => _repository.create(params);
}
