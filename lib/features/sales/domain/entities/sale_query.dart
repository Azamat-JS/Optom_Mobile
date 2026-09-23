import 'package:bsmart/core/enums/sale_enums.dart';

/// Mirrors `SaleQueryDto` exactly.
class SaleQuery {
  const SaleQuery({this.page = 1, this.limit = 20, this.type, this.status, this.customerId, this.search});

  final int page;
  final int limit;
  final SaleType? type;
  final SaleStatus? status;
  final String? customerId;
  final String? search;

  SaleQuery copyWith({int? page, int? limit, SaleType? type, String? customerId, String? search}) {
    return SaleQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      type: type ?? this.type,
      status: status,
      customerId: customerId ?? this.customerId,
      search: search ?? this.search,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type!.toWire(),
        if (customerId != null) 'customerId': customerId,
        if (search != null && search!.isNotEmpty) 'search': search,
      };
}
