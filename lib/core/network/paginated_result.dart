/// The `{data, meta}` envelope shared by every list endpoint in the backend
/// (`category`, `product`, `master-product`, and more to come) — confirmed
/// identical 6-field `meta` shape across all three by reading their services
/// directly: `{total, page, limit, totalPages, hasNext, hasPrev}`.
class PaginatedResult<T> {
  const PaginatedResult({required this.data, required this.meta});

  final List<T> data;
  final PaginationMeta meta;

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResult(
      data: (json['data'] as List).map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
        total: json['total'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        totalPages: json['totalPages'] as int,
        hasNext: json['hasNext'] as bool,
        hasPrev: json['hasPrev'] as bool,
      );
}
