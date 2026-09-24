import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_users/data/datasources/platform_users_remote_data_source.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_query.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_write_params.dart';
import 'package:bsmart/features/platform_users/domain/repositories/platform_users_repository.dart';

class PlatformUsersRepositoryImpl implements PlatformUsersRepository {
  PlatformUsersRepositoryImpl(this._remote);

  final PlatformUsersRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<PlatformUser>>> list(PlatformUserQuery query) async {
    try {
      return Result.ok(await _remote.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PlatformUser>> create(CreatePlatformUserParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PlatformUser>> update(String id, UpdatePlatformUserParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PlatformUser>> setActive(String id, bool isActive) async {
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
