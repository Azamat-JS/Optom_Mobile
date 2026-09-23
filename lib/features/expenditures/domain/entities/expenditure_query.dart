import 'package:bsmart/core/enums/expenditure_type.dart';

/// Filter/pagination params for `GET /expenditures` — field names mirror
/// `ExpenditureQueryDto` exactly (verified against the backend source).
class ExpenditureQuery {
  const ExpenditureQuery({this.page = 1, this.limit = 20, this.search, this.type, this.dateFrom, this.dateTo});

  final int page;
  final int limit;
  final String? search;
  final ExpenditureType? type;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  ExpenditureQuery copyWith({
    int? page,
    int? limit,
    String? search,
    ExpenditureType? type,
    bool clearType = false,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return ExpenditureQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      type: clearType ? null : (type ?? this.type),
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.isNotEmpty) 'search': search,
        if (type != null) 'type': type!.toWire(),
        if (dateFrom != null) 'dateFrom': dateFrom!.toIso8601String(),
        if (dateTo != null) 'dateTo': dateTo!.toIso8601String(),
      };
}
