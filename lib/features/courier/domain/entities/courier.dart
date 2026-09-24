/// A courier account (`COURIER` role) — SUPER_ADMIN-gated feature (per-owner
/// enable flag + seat limit), available to any `SELLER`/`RETAILER` owner,
/// not just restaurants. Locked to exactly one of the owner's stores.
class Courier {
  const Courier({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.isActive,
    required this.storeId,
    this.todayOrderCount = 0,
    required this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final bool isActive;
  final String storeId;

  /// Only meaningful for a RESTAURANT-vertical owner (delivery orders) — 0
  /// for every other vertical, which has no delivery concept yet.
  final int todayOrderCount;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();
}
