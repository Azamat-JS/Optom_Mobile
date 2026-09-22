import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT access/refresh token persistence (Keychain on iOS, EncryptedSharedPreferences
/// on Android) — deliberately separate from the Hive read-cache in [HiveBoxes],
/// since tokens are sensitive and read-cache data is not.
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'bsmart.access_token';
  static const _refreshTokenKey = 'bsmart.refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
