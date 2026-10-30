import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class ListCrmVisitsUseCase {
  ListCrmVisitsUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<PaginatedResult<CrmVisit>>> call({required String driverId, int page = 1, int limit = 10}) =>
      _repository.listVisits(driverId: driverId, page: page, limit: limit);
}
