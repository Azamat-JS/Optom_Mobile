import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_person_ref.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_write_params.dart';

abstract class RestaurantOrdersRepository {
  Future<Result<RestaurantOrder>> create(CreateRestaurantOrderParams params);

  Future<Result<List<RestaurantOrder>>> findOpen();

  Future<Result<RestaurantOrder>> findOne(String id);

  Future<Result<RestaurantOrder>> addItems(String id, List<RestaurantOrderItemInput> items);

  Future<Result<RestaurantOrder>> updateStatus(String id, RestaurantOrderStatus status);

  Future<Result<RestaurantOrder>> accept(String id);

  Future<Result<RestaurantOrder>> assignCourier(String id, String? courierId);

  Future<Result<List<RestaurantOrderPersonRef>>> listCouriers();
}
