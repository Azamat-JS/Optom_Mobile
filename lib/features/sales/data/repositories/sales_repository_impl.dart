import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/data/datasources/sales_remote_data_source.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_query.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(this._remote);

  final SalesRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<Sale>>> list(SaleQuery query) async {
    try {
      return Result.ok(await _remote.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Sale>> getById(String id) async {
    try {
      return Result.ok(await _remote.getById(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Sale>> create(CreateSaleParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Sale>> createReturn(String saleId, CreateSaleReturnParams params) async {
    try {
      return Result.ok(await _remote.createReturn(saleId, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
