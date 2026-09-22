import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}
