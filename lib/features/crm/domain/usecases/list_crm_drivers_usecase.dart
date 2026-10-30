import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class ListCrmDriversUseCase {
  ListCrmDriversUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<PaginatedResult<CrmDriver>>> call(CrmDriverQuery query) => _repository.listDrivers(query);
}
