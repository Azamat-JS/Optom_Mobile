import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';

/// A `GET /users` row — the SUPER_ADMIN-only generic user directory. Backs
/// every "management" screen in the panel (wholesalers, every retailer
/// vertical, customers, staff) via [PlatformUserQuery.role]/`.businessType`
/// rather than one entity/screen per role.
class PlatformUser {
  const PlatformUser({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.shopName,
    this.businessType,
    required this.role,
    this.avatarUrl,
    required this.isActive,
    this.lastLoginAt,
    required this.canAccessPos,
    required this.courierFeatureEnabled,
    required this.courierLimit,
    required this.waiterLimit,
    required this.createdAt,
  });

  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String? shopName;
  final BusinessType? businessType;
  final UserRole role;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? lastLoginAt;
  final bool canAccessPos;
  final bool courierFeatureEnabled;
  final int courierLimit;
  final int waiterLimit;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();
}
