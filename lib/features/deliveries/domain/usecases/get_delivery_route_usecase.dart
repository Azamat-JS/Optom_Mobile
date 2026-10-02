import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

/// Null value = routing unavailable (no server key, or no route possible).
class GetDeliveryRouteUseCase {
  GetDeliveryRouteUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<DeliveryRoute?>> call(String id) => _repository.route(id);
}
