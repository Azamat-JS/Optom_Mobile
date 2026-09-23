import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/auth_result.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthResult>> call({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) =>
      _repository.register(firstName: firstName, lastName: lastName, phone: phone, password: password);
}
