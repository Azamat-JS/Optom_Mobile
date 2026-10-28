import 'package:bsmart/core/l10n/app_l10n.dart';

/// Mirrors the backend's Prisma `UserRole` enum exactly (`Optom_Savdo/apps/server/prisma/schema.prisma`).
///
/// `sellerAdmin`/`retailerAdmin` inherit their owner's data via `managedUserId`
/// (see [Session]); `waiter`/`courier` are deliberately excluded from that
/// inheritance server-side and must be allow-listed per screen instead.
enum UserRole {
  superAdmin,
  seller,
  sellerAdmin,
  retailer,
  retailerAdmin,
  customer,
  waiter,
  courier,

  /// Agents (Optom_Savdo CLAUDE.md "Agents (Dillers)"): a lead agent (diller) is created by a
  /// SELLER/RETAILER owner and runs its own ledger; a staff agent is created by a lead agent and
  /// sells from the lead agent's stock. Both land on `/agent`.
  leadAgent,
  agent;

  static UserRole fromWire(String value) => switch (value) {
        'SUPER_ADMIN' => UserRole.superAdmin,
        'SELLER' => UserRole.seller,
        'SELLER_ADMIN' => UserRole.sellerAdmin,
        'RETAILER' => UserRole.retailer,
        'RETAILER_ADMIN' => UserRole.retailerAdmin,
        'CUSTOMER' => UserRole.customer,
        'WAITER' => UserRole.waiter,
        'COURIER' => UserRole.courier,
        'LEAD_AGENT' => UserRole.leadAgent,
        'AGENT' => UserRole.agent,
        _ => throw ArgumentError('Unknown UserRole from backend: $value'),
      };

  String toWire() => switch (this) {
        UserRole.superAdmin => 'SUPER_ADMIN',
        UserRole.seller => 'SELLER',
        UserRole.sellerAdmin => 'SELLER_ADMIN',
        UserRole.retailer => 'RETAILER',
        UserRole.retailerAdmin => 'RETAILER_ADMIN',
        UserRole.customer => 'CUSTOMER',
        UserRole.waiter => 'WAITER',
        UserRole.courier => 'COURIER',
        UserRole.leadAgent => 'LEAD_AGENT',
        UserRole.agent => 'AGENT',
      };

  bool get isSellerFamily => this == UserRole.seller || this == UserRole.sellerAdmin;
  bool get isRetailerFamily => this == UserRole.retailer || this == UserRole.retailerAdmin;
  bool get isStaff => this == UserRole.sellerAdmin || this == UserRole.retailerAdmin;
  bool get isAgent => this == UserRole.leadAgent || this == UserRole.agent;

  /// Display label in the active UI language — used by the SUPER_ADMIN user-management screens
  /// (Phase 3), which are the first place this app shows a raw role list to
  /// a human rather than branching behavior on it.
  String get label => appL10n.roleLabel(name);
}
