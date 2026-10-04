import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

/// Courier step: accept → pickup → arrive → complete.
class AdvanceDeliveryUseCase {
  AdvanceDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery>> call(String id, DeliveryAction action) => _repository.advance(id, action);
}

/// Hand over — with the customer's code when `handover.pending` (Phase 7 N2).
class CompleteDeliveryUseCase {
  CompleteDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery>> call(String id, {String? code}) => _repository.complete(id, code: code);
}

/// "Yetkazib bo'lmadi" — the courier couldn't hand it over.
class FailDeliveryUseCase {
  FailDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery>> call(String id, DeliveryFailReason reason, {String? note}) =>
      _repository.fail(id, reason, note: note);
}
