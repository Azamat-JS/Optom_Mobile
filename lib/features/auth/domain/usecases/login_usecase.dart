import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/auth_result.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';

/// Single-purpose (SOLID's Single Responsibility) — a thin wrapper over
/// [AuthRepository.login], but a named use-case class keeps every business
/// operation independently testable/mockable regardless of how thin it is.
class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResult>> call({required String phone, required String password}) {
    return _repository.login(phone: phone, password: password);
  }
}
