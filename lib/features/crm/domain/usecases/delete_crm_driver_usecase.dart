import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class DeleteCrmDriverUseCase {
  DeleteCrmDriverUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteDriver(id);
}
