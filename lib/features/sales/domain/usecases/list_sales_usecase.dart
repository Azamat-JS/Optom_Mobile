import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_query.dart';
import 'package:bsmart/features/sales/domain/repositories/sales_repository.dart';

class ListSalesUseCase {
  ListSalesUseCase(this._repository);

  final SalesRepository _repository;

  Future<Result<PaginatedResult<Sale>>> call(SaleQuery query) => _repository.list(query);
}
