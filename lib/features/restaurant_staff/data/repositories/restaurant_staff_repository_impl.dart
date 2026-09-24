import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/restaurant_staff/data/datasources/restaurant_staff_remote_data_source.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_list_result.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter_write_params.dart';
import 'package:bsmart/features/restaurant_staff/domain/repositories/restaurant_staff_repository.dart';

class RestaurantStaffRepositoryImpl implements RestaurantStaffRepository {
  RestaurantStaffRepositoryImpl(this._remote);

  final RestaurantStaffRemoteDataSource _remote;

  @override
  Future<Result<WaiterListResult>> list({String? search}) async {
    try {
      return Result.ok(await _remote.list(search: search));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Waiter>> create(CreateWaiterParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Waiter>> update(String id, UpdateWaiterParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Waiter>> setActive(String id, bool isActive) async {
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
