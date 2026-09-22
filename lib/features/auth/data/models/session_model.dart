import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/utils/jwt_decoder.dart';
import 'package:bsmart/features/auth/domain/entities/session.dart';

/// Builds a [Session] by decoding the access token's JWT payload — mirrors
/// the backend's `JwtPayload` shape exactly (`sub`, `role`, `managedUserId?`,
/// `storeId?`, `canAccessPos`, `ownerRole?`, `businessType?`).
Session sessionFromTokens({required String accessToken, required String refreshToken}) {
  final claims = decodeJwtPayload(accessToken);
  return Session(
    accessToken: accessToken,
    refreshToken: refreshToken,
    userId: claims['sub'] as String,
    role: UserRole.fromWire(claims['role'] as String),
    managedUserId: claims['managedUserId'] as String?,
    storeId: claims['storeId'] as String?,
    canAccessPos: claims['canAccessPos'] as bool? ?? false,
    ownerRole: claims['ownerRole'] != null ? UserRole.fromWire(claims['ownerRole'] as String) : null,
    businessType:
        claims['businessType'] != null ? BusinessType.fromWire(claims['businessType'] as String) : null,
  );
}
