import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

class GetDeliveryUseCase {
  GetDeliveryUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<Delivery>> call(String id) => _repository.get(id);
}
