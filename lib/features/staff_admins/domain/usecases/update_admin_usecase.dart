import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_write_params.dart';
import 'package:bsmart/features/staff_admins/domain/repositories/admins_repository.dart';

class UpdateAdminUseCase {
  UpdateAdminUseCase(this._repository);

  final AdminsRepository _repository;

  Future<Result<Admin>> call(String id, UpdateAdminParams params) => _repository.update(id, params);
}
