import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

/// Courier step: accept → pickup → arrive → complete.
class AdvanceDeliveryUseCase {
  AdvanceDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery>> call(String id, DeliveryAction action) => _repository.advance(id, action);
}
