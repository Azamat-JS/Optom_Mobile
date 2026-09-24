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
  courier;

  static UserRole fromWire(String value) => switch (value) {
        'SUPER_ADMIN' => UserRole.superAdmin,
        'SELLER' => UserRole.seller,
        'SELLER_ADMIN' => UserRole.sellerAdmin,
        'RETAILER' => UserRole.retailer,
        'RETAILER_ADMIN' => UserRole.retailerAdmin,
        'CUSTOMER' => UserRole.customer,
        'WAITER' => UserRole.waiter,
        'COURIER' => UserRole.courier,
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
      };

  bool get isSellerFamily => this == UserRole.seller || this == UserRole.sellerAdmin;
  bool get isRetailerFamily => this == UserRole.retailer || this == UserRole.retailerAdmin;
  bool get isStaff => this == UserRole.sellerAdmin || this == UserRole.retailerAdmin;

  /// Uzbek display label — used by the SUPER_ADMIN user-management screens
  /// (Phase 3), which are the first place this app shows a raw role list to
  /// a human rather than branching behavior on it.
  String get label => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.seller => 'Optomchi',
        UserRole.sellerAdmin => 'Optomchi xodimi',
        UserRole.retailer => "Do'konchi",
        UserRole.retailerAdmin => "Do'konchi xodimi",
        UserRole.customer => 'Mijoz',
        UserRole.waiter => 'Ofitsiant',
        UserRole.courier => 'Kuryer',
      };
}
