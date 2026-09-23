import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_query.dart';
import 'package:bsmart/features/staff_admins/domain/repositories/admins_repository.dart';

class ListAdminsUseCase {
  ListAdminsUseCase(this._repository);

  final AdminsRepository _repository;

  Future<Result<PaginatedResult<Admin>>> call(AdminQuery query) => _repository.list(query);
}
