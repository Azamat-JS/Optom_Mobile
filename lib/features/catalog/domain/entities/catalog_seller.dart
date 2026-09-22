/// `GET /catalog/sellers` — active wholesalers a RETAILER may source from.
class CatalogSeller {
  const CatalogSeller({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? avatarUrl;

  String get fullName => '$firstName $lastName';
}

/// `GET /catalog/sellers/:sellerId/stores` — a "select branch" step before
/// browsing a multi-store seller's products.
class CatalogStore {
  const CatalogStore({required this.id, required this.name, this.address});

  final String id;
  final String name;
  final String? address;
}
