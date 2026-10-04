import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/assignable_courier.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_tracking_link.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

// Owner/admin delivery management for B2C orders (one use case per repository method).

class ListAssignableCouriersUseCase {
  ListAssignableCouriersUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<List<AssignableCourier>>> call() => _repository.assignableCouriers();
}

class CreateDeliveryUseCase {
  CreateDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  /// [courierId] null = offer to all couriers.
  Future<Result<Delivery>> call(String orderId, {String? courierId}) => _repository.create(orderId, courierId: courierId);
}

class ReassignDeliveryUseCase {
  ReassignDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery>> call(String id, {String? courierId}) => _repository.reassign(id, courierId: courierId);
}

class CancelDeliveryUseCase {
  CancelDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery>> call(String id, {String? reason}) => _repository.cancel(id, reason: reason);
}

class WaiveHandoverUseCase {
  WaiveHandoverUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery>> call(String id) => _repository.waiveHandover(id);
}

class RevokeTrackingLinksUseCase {
  RevokeTrackingLinksUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<int>> call(String id) => _repository.revokeTrackingLinks(id);
}

class GetRestaurantOrderDeliveryUseCase {
  GetRestaurantOrderDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery?>> call(String restaurantOrderId) => _repository.byRestaurantOrder(restaurantOrderId);
}

class CreateTrackingLinkUseCase {
  CreateTrackingLinkUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<DeliveryTrackingLink>> call({required String restaurantOrderId}) =>
      _repository.createTrackingLink(restaurantOrderId: restaurantOrderId);
}
