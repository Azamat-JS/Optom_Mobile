import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/repositories/platform_users_repository.dart';

class SetPlatformUserActiveUseCase {
  SetPlatformUserActiveUseCase(this._repository);

  final PlatformUsersRepository _repository;

  Future<Result<PlatformUser>> call(String id, bool isActive) => _repository.setActive(id, isActive);
}
