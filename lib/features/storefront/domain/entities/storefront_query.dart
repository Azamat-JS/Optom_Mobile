/// Mirrors `CatalogQueryDto` (the query DTO `/public/catalog/products` also
/// uses) — `sellerRole` is deliberately not exposed here, the data source
/// always hardcodes it to `RETAILER` (see `StorefrontProduct`'s doc comment).
class StorefrontQuery {
  const StorefrontQuery({this.page = 1, this.limit = 20, this.search, this.categoryId, this.sellerId});

  final int page;
  final int limit;
  final String? search;
  final String? categoryId;
  final String? sellerId;

  StorefrontQuery copyWith({int? page, String? search, bool clearSearch = false, String? categoryId, bool clearCategory = false}) {
    return StorefrontQuery(
      page: page ?? this.page,
      limit: limit,
      search: clearSearch ? null : (search ?? this.search),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      sellerId: sellerId,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        'sellerRole': 'RETAILER',
        if (search != null && search!.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
        if (sellerId != null) 'sellerId': sellerId,
      };
}
