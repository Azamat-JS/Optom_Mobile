import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_tables/data/datasources/restaurant_tables_remote_data_source.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table_write_params.dart';
import 'package:bsmart/features/restaurant_tables/domain/repositories/restaurant_tables_repository.dart';

class RestaurantTablesRepositoryImpl implements RestaurantTablesRepository {
  RestaurantTablesRepositoryImpl(this._remote);

  final RestaurantTablesRemoteDataSource _remote;

  @override
  Future<Result<List<RestaurantTable>>> list({String? search}) async {
    try {
      final result = await _remote.list(search: search);
      return Result.ok(result.data);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<RestaurantTable>> create(CreateRestaurantTableParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<RestaurantTable>> update(String id, UpdateRestaurantTableParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _remote.delete(id);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
