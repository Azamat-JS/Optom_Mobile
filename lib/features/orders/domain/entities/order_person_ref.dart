import 'package:bsmart/core/enums/user_role.dart';

/// A lightweight reference to a person embedded on an order (seller, buyer,
/// createdBy, or a status-history actor) — each endpoint selects a slightly
/// different subset of fields, so every field here is optional except id.
class OrderPersonRef {
  const OrderPersonRef({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.role,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole? role;

  String get fullName => '$firstName $lastName';
}
