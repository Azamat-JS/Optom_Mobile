import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';

/// Used for re-confirming identity before a sensitive action (e.g. the POS
/// lock-screen unlock, per the reference backend's comment on this endpoint)
/// — does not re-issue tokens or bump `lastLoginAt`.
class VerifyPasswordUseCase {
  VerifyPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String password) => _repository.verifyPassword(password);
}
