import 'package:bsmart/core/storage/secure_token_storage.dart';
import 'package:bsmart/features/auth/data/models/session_model.dart';
import 'package:bsmart/features/auth/domain/entities/session.dart';

/// Wraps token persistence + JWT decoding for the repository. Holds no
/// network/Dio knowledge — that's [AuthRemoteDataSource]'s job.
class AuthLocalDataSource {
  AuthLocalDataSource(this._tokenStorage);

  final SecureTokenStorage _tokenStorage;

  Future<void> saveSession(Session session) {
    return _tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }

  /// Rebuilds a [Session] from whatever's in secure storage, or `null` if
  /// there's nothing there / the stored token can't be decoded.
  Future<Session?> restoreSession() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (accessToken == null || refreshToken == null) return null;
    try {
      return sessionFromTokens(accessToken: accessToken, refreshToken: refreshToken);
    } on FormatException {
      return null;
    }
  }

  Future<String?> readRefreshToken() => _tokenStorage.readRefreshToken();

  Future<void> clear() => _tokenStorage.clear();
}
