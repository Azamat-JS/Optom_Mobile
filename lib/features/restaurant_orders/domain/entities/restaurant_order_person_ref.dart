/// A lightweight person reference embedded on a restaurant order
/// (createdBy/waiter/courier) — deliberately not a reuse of
/// `features/orders`' own `OrderPersonRef` (a feature's domain shouldn't
/// depend on another feature's domain — same rule already stated for
/// `Product.ProductCategoryRef`), just a small duplicate.
class RestaurantOrderPersonRef {
  const RestaurantOrderPersonRef({required this.id, required this.firstName, required this.lastName});

  final String id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName'.trim();
}
