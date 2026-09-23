import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_query.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';

abstract class SalesRepository {
  Future<Result<PaginatedResult<Sale>>> list(SaleQuery query);

  Future<Result<Sale>> getById(String id);

  Future<Result<Sale>> create(CreateSaleParams params);

  Future<Result<Sale>> createReturn(String saleId, CreateSaleReturnParams params);
}
