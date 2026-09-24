/// Mirrors `CategoryQueryDto` — the flat, unpaginated-tree admin-list query
/// (as opposed to [CategoriesRepository.getRootCategoriesWithChildren]'s
/// fixed 2-level-tree shape used by the product-form picker).
class CategoryQuery {
  const CategoryQuery({this.page = 1, this.limit = 20, this.search, this.parentId, this.isActive});

  final int page;
  final int limit;
  final String? search;
  final String? parentId;
  final bool? isActive;

  CategoryQuery copyWith({int? page, String? search, String? parentId, bool? isActive}) {
    return CategoryQuery(
      page: page ?? this.page,
      limit: limit,
      search: search ?? this.search,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (parentId != null) 'parentId': parentId,
        if (isActive != null) 'isActive': isActive,
      };
}
