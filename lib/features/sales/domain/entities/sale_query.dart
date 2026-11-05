import 'package:bsmart/core/enums/sale_enums.dart';

/// `SaleQueryDto.kind`: real sales only, or manual revenues only. Null = both.
enum SaleKind {
  sale,
  manual;

  String toWire() => name;
}

/// Mirrors `SaleQueryDto` exactly.
class SaleQuery {
  const SaleQuery({this.page = 1, this.limit = 20, this.type, this.status, this.customerId, this.search, this.kind});

  final int page;
  final int limit;
  final SaleType? type;
  final SaleStatus? status;
  final String? customerId;
  final String? search;
  final SaleKind? kind;

  SaleQuery copyWith({int? page, int? limit, SaleType? type, String? customerId, String? search}) {
    return SaleQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      type: type ?? this.type,
      status: status,
      customerId: customerId ?? this.customerId,
      search: search ?? this.search,
      kind: kind,
    );
  }

  /// [kind] is nullable on purpose (null = both), so it has its own setter.
  SaleQuery withKind(SaleKind? kind) => SaleQuery(
        page: 1,
        limit: limit,
        type: type,
        status: status,
        customerId: customerId,
        search: search,
        kind: kind,
      );

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type!.toWire(),
        if (customerId != null) 'customerId': customerId,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (kind != null) 'kind': kind!.toWire(),
      };
}
