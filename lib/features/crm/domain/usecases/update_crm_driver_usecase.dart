import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class UpdateCrmDriverUseCase {
  UpdateCrmDriverUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<CrmDriver>> call(String id, UpdateCrmDriverParams params) => _repository.updateDriver(id, params);
}
