import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';

PlatformUser platformUserFromJson(Map<String, dynamic> json) => PlatformUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      shopName: json['shopName'] as String?,
      businessType: json['businessType'] != null ? BusinessType.fromWire(json['businessType'] as String) : null,
      role: UserRole.fromWire(json['role'] as String),
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt'] as String) : null,
      canAccessPos: json['canAccessPos'] as bool? ?? false,
      courierFeatureEnabled: json['courierFeatureEnabled'] as bool? ?? false,
      courierLimit: (json['courierLimit'] as num?)?.toInt() ?? 0,
      waiterLimit: (json['waiterLimit'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
