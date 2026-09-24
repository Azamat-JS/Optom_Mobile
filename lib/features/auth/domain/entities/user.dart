import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';

/// A lightweight reference to an owner, as returned nested on a staff
/// account's profile (`managedUser` in the backend's `getMe()`/login response).
class OwnerRef {
  const OwnerRef({required this.id, required this.firstName, required this.lastName});

  final String id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';
}

/// The authenticated user's profile — from the `user` object on
/// login/register, or from `GET /auth/me`. See [Session] for the
/// authorization-claims counterpart.
class User {
  const User({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.avatarUrl,
    this.shopName,
    this.businessType,
    this.storeId,
    required this.canAccessPos,
    this.courierFeatureEnabled = false,
    this.courierLimit = 0,
    this.waiterLimit = 0,
    this.ownerRole,
    this.managedUserId,
    this.isActive,
    this.owner,
  });

  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? avatarUrl;
  final String? shopName;
  final BusinessType? businessType;
  final String? storeId;
  final bool canAccessPos;
  final bool courierFeatureEnabled;
  final int courierLimit;

  /// SUPER_ADMIN-editable cap on active WAITER accounts — only meaningful
  /// for a RESTAURANT-vertical RETAILER owner (no companion enable switch,
  /// unlike courier — every restaurant owner already has waiters as a
  /// baseline capability).
  final int waiterLimit;
  final UserRole? ownerRole;
  final String? managedUserId;
  final bool? isActive;

  /// Non-null for `_ADMIN`/`WAITER`/`COURIER` — their owner's basic info.
  final OwnerRef? owner;

  String get fullName => '$firstName $lastName';
  bool get isStaff => managedUserId != null;
}
