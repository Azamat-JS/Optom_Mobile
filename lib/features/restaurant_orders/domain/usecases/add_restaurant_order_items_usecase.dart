import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';
import 'package:bsmart/features/restaurant_orders/domain/repositories/restaurant_orders_repository.dart';

class AddRestaurantOrderItemsUseCase {
  AddRestaurantOrderItemsUseCase(this._repository);

  final RestaurantOrdersRepository _repository;

  Future<Result<RestaurantOrder>> call(String id, List<RestaurantOrderItemInput> items) =>
      _repository.addItems(id, items);
}
