/// A panel admin (`SELLER_ADMIN`/`RETAILER_ADMIN`) created by the current
/// owner — locked to exactly one of the owner's stores. Owner-only resource;
/// `_ADMIN`/`WAITER`/`COURIER` sessions never reach this feature (see
/// `RoleGate`-style hiding in `StoresListScreen`/`AdminsListScreen`'s nav
/// entry point, and the backend's own `assertIsOwner` enforcement).
class Admin {
  const Admin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.isActive,
    required this.storeId,
    required this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final bool isActive;
  final String storeId;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();
}
