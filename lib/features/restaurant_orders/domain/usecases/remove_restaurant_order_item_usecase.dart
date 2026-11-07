import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/repositories/restaurant_orders_repository.dart';

/// `POST /restaurant-orders/:id/items/:itemId/remove` — owner/admin takes dishes off an unpaid
/// order; [quantity] null = the whole line. The kitchen is told by the server.
class RemoveRestaurantOrderItemUseCase {
  RemoveRestaurantOrderItemUseCase(this._repository);

  final RestaurantOrdersRepository _repository;

  Future<Result<RestaurantOrder>> call(String id, String itemId, {int? quantity}) =>
      _repository.removeItem(id, itemId, quantity);
}
