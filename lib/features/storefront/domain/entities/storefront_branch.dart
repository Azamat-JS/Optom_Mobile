/// One active store (branch) of a shop — `GET /public/catalog/sellers/:id/stores`
/// (default store first, then by name).
class StorefrontBranch {
  const StorefrontBranch({required this.id, required this.name, this.address});

  final String id;
  final String name;
  final String? address;
}
