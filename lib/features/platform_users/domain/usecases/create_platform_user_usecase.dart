import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_write_params.dart';
import 'package:bsmart/features/platform_users/domain/repositories/platform_users_repository.dart';

class CreatePlatformUserUseCase {
  CreatePlatformUserUseCase(this._repository);

  final PlatformUsersRepository _repository;

  Future<Result<PlatformUser>> call(CreatePlatformUserParams params) => _repository.create(params);
}
