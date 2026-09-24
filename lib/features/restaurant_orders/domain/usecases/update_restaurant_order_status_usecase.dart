import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/repositories/restaurant_orders_repository.dart';

class UpdateRestaurantOrderStatusUseCase {
  UpdateRestaurantOrderStatusUseCase(this._repository);

  final RestaurantOrdersRepository _repository;

  Future<Result<RestaurantOrder>> call(String id, RestaurantOrderStatus status) =>
      _repository.updateStatus(id, status);
}
