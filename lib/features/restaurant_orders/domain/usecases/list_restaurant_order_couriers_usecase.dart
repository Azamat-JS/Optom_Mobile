import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_person_ref.dart';
import 'package:bsmart/features/restaurant_orders/domain/repositories/restaurant_orders_repository.dart';

class ListRestaurantOrderCouriersUseCase {
  ListRestaurantOrderCouriersUseCase(this._repository);

  final RestaurantOrdersRepository _repository;

  Future<Result<List<RestaurantOrderPersonRef>>> call() => _repository.listCouriers();
}
