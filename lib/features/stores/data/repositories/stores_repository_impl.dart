import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/stores/data/datasources/stores_remote_data_source.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/entities/store_write_params.dart';
import 'package:bsmart/features/stores/domain/repositories/stores_repository.dart';

class StoresRepositoryImpl implements StoresRepository {
  StoresRepositoryImpl(this._remote);

  final StoresRemoteDataSource _remote;

  @override
  Future<Result<List<Store>>> list() async {
    try {
      return Result.ok(await _remote.list());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Store>> create(CreateStoreParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Store>> update(String id, UpdateStoreParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Store>> setActive(String id, bool isActive) async {
    try {
      return Result.ok(await _remote.setActive(id, isActive));
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
