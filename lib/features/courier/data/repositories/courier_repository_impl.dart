import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/courier/data/datasources/courier_remote_data_source.dart';
import 'package:bsmart/features/courier/domain/entities/courier.dart';
import 'package:bsmart/features/courier/domain/entities/courier_list_result.dart';
import 'package:bsmart/features/courier/domain/entities/courier_write_params.dart';
import 'package:bsmart/features/courier/domain/repositories/courier_repository.dart';

class CourierRepositoryImpl implements CourierRepository {
  CourierRepositoryImpl(this._remote);

  final CourierRemoteDataSource _remote;

  @override
  Future<Result<CourierListResult>> list({String? search}) async {
    try {
      return Result.ok(await _remote.list(search: search));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Courier>> create(CreateCourierParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Courier>> update(String id, UpdateCourierParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Courier>> setActive(String id, bool isActive) async {
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
