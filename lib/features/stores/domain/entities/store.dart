/// One of the owner's physical stores/branches (`Store` model) — owner-only
/// (SELLER/RETAILER); `_ADMIN`/`WAITER`/`COURIER` staff never manage this
/// roster, only work within whichever store they're locked to.
class Store {
  const Store({
    required this.id,
    required this.name,
    this.address,
    required this.isActive,
    required this.isDefault,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? address;
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
}
