import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/repositories/admins_repository.dart';

class SetAdminActiveUseCase {
  SetAdminActiveUseCase(this._repository);

  final AdminsRepository _repository;

  Future<Result<Admin>> call(String id, bool isActive) => _repository.setActive(id, isActive);
}
