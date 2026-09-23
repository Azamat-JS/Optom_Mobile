/// Filter/pagination params for `GET /customers` — field names mirror
/// `CustomerQueryDto` exactly (verified against the backend source).
class CustomerQuery {
  const CustomerQuery({this.page = 1, this.limit = 20, this.search, this.isActive});

  final int page;
  final int limit;
  final String? search;
  final bool? isActive;

  CustomerQuery copyWith({int? page, int? limit, String? search, bool? isActive}) {
    return CustomerQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (isActive != null) 'isActive': isActive,
      };
}
