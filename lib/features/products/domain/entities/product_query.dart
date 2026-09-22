import 'package:bsmart/core/enums/product_unit.dart';

/// Filter/sort params for `GET /products` — field names mirror
/// `ProductQueryDto` exactly (verified against the backend source).
class ProductQuery {
  const ProductQuery({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.categoryId,
    this.barcode,
    this.isActive,
    this.unit,
    this.sortBy,
    this.sortOrder,
  });

  final int page;
  final int limit;
  final String? search;
  final String? categoryId;

  /// Exact-match lookup (e.g. from a `mobile_scanner` camera scan) — distinct
  /// from [search], which also matches by name.
  final String? barcode;
  final bool? isActive;
  final ProductUnit? unit;
  final String? sortBy;
  final String? sortOrder;

  ProductQuery copyWith({
    int? page,
    int? limit,
    String? search,
    String? categoryId,
    bool? isActive,
    ProductUnit? unit,
  }) {
    return ProductQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      unit: unit ?? this.unit,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
        if (barcode != null) 'barcode': barcode,
        if (isActive != null) 'isActive': isActive,
        if (unit != null) 'unit': unit!.toWire(),
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };
}
