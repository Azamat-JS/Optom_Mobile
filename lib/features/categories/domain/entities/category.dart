/// A category (or subcategory — max 2 levels, enforced server-side).
/// Category CRUD is SUPER_ADMIN-only on the backend; SELLER/RETAILER only
/// ever browse this list (e.g. as a picker when creating a product), never
/// create/edit/delete a category themselves. Full management UI is Phase 3.
///
/// [children] is populated when fetched via
/// [CategoriesRepository.getRootCategoriesWithChildren] (root category rows
/// carry their direct children embedded, per the backend's `GET
/// /categories?parentId=root` response) — empty for a leaf/subcategory row.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.icon,
    required this.sortOrder,
    required this.isActive,
    this.parentId,
    this.parentName,
    this.children = const [],
  });

  final String id;
  final String name;
  final String slug;
  final String? imageUrl;
  final String? icon;
  final int sortOrder;
  final bool isActive;
  final String? parentId;
  final String? parentName;
  final List<Category> children;

  bool get isRoot => parentId == null;
}
