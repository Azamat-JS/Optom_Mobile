import 'dart:convert';

/// Decodes a JWT's payload segment locally (no signature verification — the
/// backend is the only party that needs to verify signatures; the app just
/// needs the claims to make UI/routing decisions without an extra round trip).
///
/// Mirrors the reference web app's `decodeJwt` in `lib/api/client.ts`.
Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw const FormatException('Invalid JWT: expected 3 dot-separated segments.');
  }
  final normalized = base64Url.normalize(parts[1]);
  final payload = utf8.decode(base64Url.decode(normalized));
  return jsonDecode(payload) as Map<String, dynamic>;
}
