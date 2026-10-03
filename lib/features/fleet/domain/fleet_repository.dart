import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/fleet/domain/fleet_courier.dart';

abstract interface class FleetRepository {
  Future<Result<List<FleetCourier>>> fleet();
}

class GetFleetUseCase {
  GetFleetUseCase(this._repository);

  final FleetRepository _repository;

  Future<Result<List<FleetCourier>>> call() => _repository.fleet();
}
