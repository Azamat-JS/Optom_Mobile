import 'package:bsmart/features/auth/domain/entities/session.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';

/// What a successful login yields: the JWT-derived [Session] plus the
/// [User] profile object the backend returns inline (so the first screen
/// after login doesn't need a second `GET /auth/me` round trip).
class AuthResult {
  const AuthResult({required this.session, required this.user});

  final Session session;
  final User user;
}
