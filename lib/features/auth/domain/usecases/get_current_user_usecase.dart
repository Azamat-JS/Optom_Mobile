import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call() => _repository.getCurrentUser();
}
