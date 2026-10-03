/// A courier the owner/admin can hand a delivery to (`GET /deliveries/couriers`).
class AssignableCourier {
  const AssignableCourier({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.online,
    required this.activeDeliveries,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? phone;

  /// Sharing location right now.
  final bool online;

  /// Accepted, unfinished deliveries.
  final int activeDeliveries;

  String get fullName => '$firstName $lastName'.trim();
}
