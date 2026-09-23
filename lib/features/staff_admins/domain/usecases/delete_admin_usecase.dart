import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/staff_admins/domain/repositories/admins_repository.dart';

class DeleteAdminUseCase {
  DeleteAdminUseCase(this._repository);

  final AdminsRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
