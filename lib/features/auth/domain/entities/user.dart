import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';

/// A lightweight reference to an owner, as returned nested on a staff
/// account's profile (`managedUser` in the backend's `getMe()`/login response).
class OwnerRef {
  const OwnerRef({required this.id, required this.firstName, required this.lastName, this.shopName});

  final String id;
  final String firstName;
  final String lastName;

  /// Only on [User.agentOwner] — the business name a lead agent works for.
  final String? shopName;

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
    this.agentOwner,
    this.phoneVerified = false,
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

  /// Non-null for `_ADMIN`/`WAITER`/`COURIER` — their owner's basic info. For a staff agent it's
  /// its lead agent.
  final OwnerRef? owner;

  /// Lead agent only (`GET /auth/me`): the business owner it works for.
  final OwnerRef? agentOwner;

  /// Phase 6: the phone was proven via Telegram. Phone-matched features
  /// (restaurant deliveries staff entered for this number, debts) only work
  /// once it's true — see [VerifyPhoneBanner].
  final bool phoneVerified;

  String get fullName => '$firstName $lastName';
  bool get isStaff => managedUserId != null;

  /// A CUSTOMER who still has to confirm their number for phone-matched features.
  bool get needsPhoneVerification => role == UserRole.customer && !phoneVerified;
}
