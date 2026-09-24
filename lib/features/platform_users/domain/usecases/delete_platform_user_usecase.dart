import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_users/domain/repositories/platform_users_repository.dart';

class DeletePlatformUserUseCase {
  DeletePlatformUserUseCase(this._repository);

  final PlatformUsersRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
