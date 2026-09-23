/// Mirrors `AdminQueryDto`.
class AdminQuery {
  const AdminQuery({this.page = 1, this.limit = 100, this.search, this.storeId});

  final int page;
  final int limit;
  final String? search;
  final String? storeId;

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (storeId != null) 'storeId': storeId,
      };
}
