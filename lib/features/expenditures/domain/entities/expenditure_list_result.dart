import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';

/// `GET /expenditures`'s `{data, meta}` envelope — same 6-field pagination
/// shape as `PaginatedResult`, plus `meta.totalAmount` (the `Decimal` sum
/// across every *filtered* row, not just the current page) which no other
/// list endpoint in this app returns, so this isn't just `PaginatedResult`.
class ExpenditureListResult {
  const ExpenditureListResult({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    required this.totalAmount,
  });

  final List<Expenditure> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final double totalAmount;
}
