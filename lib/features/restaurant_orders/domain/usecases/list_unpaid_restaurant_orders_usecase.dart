import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/repositories/restaurant_orders_repository.dart';

/// `GET /restaurant-orders/unpaid` — the restaurant Kassa's tables view (owner/admin).
class ListUnpaidRestaurantOrdersUseCase {
  ListUnpaidRestaurantOrdersUseCase(this._repository);

  final RestaurantOrdersRepository _repository;

  Future<Result<List<RestaurantOrder>>> call() => _repository.findUnpaid();
}
