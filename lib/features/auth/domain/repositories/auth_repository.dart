import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/auth_result.dart';
import 'package:bsmart/features/auth/domain/entities/session.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';

/// Presentation and other domain layers depend on this abstraction, never on
/// [AuthRepositoryImpl] directly (SOLID's Dependency Inversion) — `get_it`
/// is what resolves which implementation a caller actually receives.
///
/// Deliberately has no `register()` — `POST /auth/register` always creates a
/// `CUSTOMER` account server-side (see `auth.service.ts`); SELLER/RETAILER
/// accounts are provisioned by SUPER_ADMIN via the `user` module, not
/// self-registered. Customer self-registration is Phase 2 scope.
abstract class AuthRepository {
  Future<Result<AuthResult>> login({required String phone, required String password});

  /// Restores a session from secure storage on app cold-start, if a valid
  /// (non-expired, by claim) access token exists. Does not hit the network.
  Future<Session?> restoreSession();

  Future<Result<User>> getCurrentUser();

  Future<Result<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? currentPassword,
    String? newPassword,
    String? avatarUrl,
  });

  Future<Result<void>> verifyPassword(String password);

  Future<Result<void>> logout();
}
