import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class AddCrmVehicleUseCase {
  AddCrmVehicleUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<void>> call(String driverId, CrmVehicleParams params) => _repository.addVehicle(driverId, params);
}
