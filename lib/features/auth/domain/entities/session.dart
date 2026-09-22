import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';

/// The authenticated JWT's claims, decoded locally — mirrors the backend's
/// `JwtPayload` exactly (`Optom_Savdo/apps/server/src/tools/guards/jwt.guard.ts`
/// and `auth.service.ts#issueTokens`). Kept separate from [User] (the richer
/// profile record) because these fields are what's needed for *authorization
/// and routing* decisions immediately after login/app-launch, before any
/// extra network round trip.
class Session {
  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.role,
    this.managedUserId,
    this.storeId,
    required this.canAccessPos,
    this.ownerRole,
    this.businessType,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final UserRole role;

  /// Set only for `_ADMIN`/`WAITER`/`COURIER` — the id whose tenant data this
  /// session transparently shares (see the backend's `TenantContext`).
  final String? managedUserId;

  /// Set only for locked staff — their store is fixed server-side, so no
  /// `X-Store-Id` switcher is ever shown to them.
  final String? storeId;

  final bool canAccessPos;

  /// Routing-only: for WAITER/COURIER, which family (`seller`/`retailer`)
  /// their owner belongs to, so the app knows which shell to route into.
  final UserRole? ownerRole;

  final BusinessType? businessType;

  bool get isStaff => managedUserId != null;
  bool get isLockedToStore => storeId != null;

  Session copyWith({String? accessToken, String? refreshToken}) => Session(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        userId: userId,
        role: role,
        managedUserId: managedUserId,
        storeId: storeId,
        canAccessPos: canAccessPos,
        ownerRole: ownerRole,
        businessType: businessType,
      );
}
