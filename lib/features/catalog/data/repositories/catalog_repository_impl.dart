import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_product.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_query.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';
import 'package:bsmart/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<Result<List<CatalogSeller>>> listSellers() async {
    try {
      return Result.ok(await _remote.listSellers());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<List<CatalogStore>>> listStoresForSeller(String sellerId) async {
    try {
      return Result.ok(await _remote.listStoresForSeller(sellerId));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PaginatedResult<CatalogProduct>>> listProducts(CatalogQuery query) async {
    try {
      return Result.ok(await _remote.listProducts(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
