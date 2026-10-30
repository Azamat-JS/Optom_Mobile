import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class CreateCrmVisitUseCase {
  CreateCrmVisitUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<CrmVisit>> call(CreateCrmVisitParams params) => _repository.createVisit(params);
}
