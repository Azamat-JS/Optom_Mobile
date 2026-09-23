import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:bsmart/features/favorites/domain/entities/favorite_product.dart';
import 'package:bsmart/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._remote);

  final FavoritesRemoteDataSource _remote;

  @override
  Future<Result<bool>> toggle(String productId) async {
    try {
      return Result.ok(await _remote.toggle(productId));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<List<FavoriteProduct>>> list() async {
    try {
      return Result.ok(await _remote.list());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<List<String>>> listIds() async {
    try {
      return Result.ok(await _remote.listIds());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
