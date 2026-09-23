import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/staff_admins/data/datasources/admins_remote_data_source.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_query.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_write_params.dart';
import 'package:bsmart/features/staff_admins/domain/repositories/admins_repository.dart';

class AdminsRepositoryImpl implements AdminsRepository {
  AdminsRepositoryImpl(this._remote);

  final AdminsRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<Admin>>> list(AdminQuery query) async {
    try {
      return Result.ok(await _remote.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Admin>> create(CreateAdminParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Admin>> update(String id, UpdateAdminParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Admin>> setActive(String id, bool isActive) async {
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
