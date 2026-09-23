/// A retailer's or seller's own B2C customer (`GET /customers` — always
/// scoped to the caller's own store, see `customer.controller.ts`). Backing
/// a `Customer` account (`role: CUSTOMER`) is created transparently
/// server-side the first time a phone number is used — this entity only
/// ever represents the tenant-owned `Customer` row, not that account.
class Customer {
  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.address,
    this.notes,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName'.trim();
}
