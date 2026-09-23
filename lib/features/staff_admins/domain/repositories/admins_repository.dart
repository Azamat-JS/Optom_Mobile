import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_query.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_write_params.dart';

abstract class AdminsRepository {
  Future<Result<PaginatedResult<Admin>>> list(AdminQuery query);

  Future<Result<Admin>> create(CreateAdminParams params);

  Future<Result<Admin>> update(String id, UpdateAdminParams params);

  Future<Result<Admin>> setActive(String id, bool isActive);

  Future<Result<void>> delete(String id);
}
