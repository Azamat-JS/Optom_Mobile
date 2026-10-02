import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

/// The courier delivery of an order (null = none yet).
class GetOrderDeliveryUseCase {
  GetOrderDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery?>> call(String orderId) => _repository.byOrder(orderId);
}
