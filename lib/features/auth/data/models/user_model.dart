import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';

/// Maps the backend's `user` object (on login) or `GET /auth/me` response —
/// both shapes are close enough (see `auth.service.ts#issueTokens`/`getMe`)
/// to share one parser; fields present in only one are nullable here.
User userFromJson(Map<String, dynamic> json) {
  final managedUser = json['managedUser'] as Map<String, dynamic>?;
  return User(
    id: json['id'] as String,
    phone: json['phone'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    role: UserRole.fromWire(json['role'] as String),
    avatarUrl: json['avatarUrl'] as String?,
    shopName: json['shopName'] as String?,
    businessType:
        json['businessType'] != null ? BusinessType.fromWire(json['businessType'] as String) : null,
    storeId: json['storeId'] as String?,
    canAccessPos: json['canAccessPos'] as bool? ?? false,
    courierFeatureEnabled: json['courierFeatureEnabled'] as bool? ?? false,
    courierLimit: (json['courierLimit'] as num?)?.toInt() ?? 0,
    waiterLimit: (json['waiterLimit'] as num?)?.toInt() ?? 0,
    ownerRole: json['ownerRole'] != null ? UserRole.fromWire(json['ownerRole'] as String) : null,
    managedUserId: json['managedUserId'] as String?,
    isActive: json['isActive'] as bool?,
    owner: managedUser == null
        ? null
        : OwnerRef(
            id: managedUser['id'] as String,
            firstName: managedUser['firstName'] as String,
            lastName: managedUser['lastName'] as String,
          ),
  );
}
