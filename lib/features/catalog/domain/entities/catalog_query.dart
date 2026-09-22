/// Mirrors `CatalogQueryDto` exactly.
class CatalogQuery {
  const CatalogQuery({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.sellerId,
    this.categoryId,
    this.storeId,
  });

  final int page;
  final int limit;
  final String? search;
  final String? sellerId;
  final String? categoryId;
  final String? storeId;

  CatalogQuery copyWith({int? page, String? search, String? categoryId, String? storeId}) {
    return CatalogQuery(
      page: page ?? this.page,
      limit: limit,
      search: search ?? this.search,
      sellerId: sellerId,
      categoryId: categoryId ?? this.categoryId,
      storeId: storeId ?? this.storeId,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (sellerId != null) 'sellerId': sellerId,
        if (categoryId != null) 'categoryId': categoryId,
        if (storeId != null) 'storeId': storeId,
      };
}
