/// A waiter account (`WAITER` role) — owner-only management, RESTAURANT
/// vertical only. Locked to exactly one of the owner's stores at creation.
class Waiter {
  const Waiter({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.isActive,
    required this.storeId,
    this.commissionPercent,
    this.todayOrderCount = 0,
    required this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final bool isActive;
  final String storeId;

  /// Optional per-order commission — folded into a restaurant order's
  /// `grandTotal` alongside the table's own service charge, and doubles as
  /// this waiter's own earnings report figure.
  final double? commissionPercent;

  /// How many restaurant orders this waiter has been stamped onto today.
  final int todayOrderCount;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();
}
