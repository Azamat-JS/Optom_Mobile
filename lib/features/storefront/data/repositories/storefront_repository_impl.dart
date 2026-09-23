import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/storefront/data/datasources/storefront_remote_data_source.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_query.dart';
import 'package:bsmart/features/storefront/domain/repositories/storefront_repository.dart';

class StorefrontRepositoryImpl implements StorefrontRepository {
  StorefrontRepositoryImpl(this._remote);

  final StorefrontRemoteDataSource _remote;

  @override
  Future<Result<List<StorefrontCategory>>> listCategories() async {
    try {
      return Result.ok(await _remote.listCategories());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PaginatedResult<StorefrontProduct>>> listProducts(StorefrontQuery query) async {
    try {
      return Result.ok(await _remote.listProducts(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<StorefrontProduct>> getProduct(String id) async {
    try {
      return Result.ok(await _remote.getProduct(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
