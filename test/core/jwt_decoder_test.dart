import 'dart:convert';

import 'package:bsmart/core/utils/jwt_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds an unsigned test JWT (no signature verification happens client
/// side — see `jwt_decoder.dart`'s doc comment on why that's fine here).
String _fakeJwt(Map<String, dynamic> claims) {
  String segment(Map<String, dynamic> json) => base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final header = segment({'alg': 'HS256', 'typ': 'JWT'});
  final payload = segment(claims);
  return '$header.$payload.fake-signature';
}

void main() {
  group('decodeJwtPayload', () {
    test('decodes claims matching the backend JwtPayload shape', () {
      final token = _fakeJwt({
        'sub': 'user_123',
        'role': 'RETAILER',
        'canAccessPos': true,
        'storeId': 'store_456',
      });

      final claims = decodeJwtPayload(token);

      expect(claims['sub'], 'user_123');
      expect(claims['role'], 'RETAILER');
      expect(claims['canAccessPos'], true);
      expect(claims['storeId'], 'store_456');
    });

    test('throws FormatException on a malformed token', () {
      expect(() => decodeJwtPayload('not-a-jwt'), throwsFormatException);
    });
  });
}
