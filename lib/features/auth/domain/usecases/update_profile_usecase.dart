import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    String? firstName,
    String? lastName,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? avatarUrl,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      currentPassword: currentPassword,
      newPassword: newPassword,
      avatarUrl: avatarUrl,
    );
  }
}
