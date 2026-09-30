import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/data/datasources/shared_cart_remote_data_source.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart_write_params.dart';
import 'package:bsmart/features/sales/domain/repositories/shared_cart_repository.dart';

class SharedCartRepositoryImpl implements SharedCartRepository {
  SharedCartRepositoryImpl(this._remote);

  final SharedCartRemoteDataSource _remote;

  @override
  Future<Result<List<SharedCart>>> list() async {
    try {
      return Result.ok(await _remote.list());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<SharedCart>> park(CreateSharedCartParams params) async {
    try {
      return Result.ok(await _remote.park(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<SharedCart>> remove(String id) async {
    try {
      return Result.ok(await _remote.remove(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
