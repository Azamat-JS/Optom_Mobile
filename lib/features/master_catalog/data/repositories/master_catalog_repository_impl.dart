import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/data/datasources/master_catalog_remote_data_source.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';

class MasterCatalogRepositoryImpl implements MasterCatalogRepository {
  MasterCatalogRepositoryImpl(this._remote);

  final MasterCatalogRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<MasterProduct>>> search({
    String? search,
    String? categoryId,
    String? barcode,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _remote.search(
        search: search,
        categoryId: categoryId,
        barcode: barcode,
        page: page,
        limit: limit,
      );
      return Result.ok(result);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<MasterProduct>> getById(String id) async {
    try {
      return Result.ok(await _remote.getById(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
