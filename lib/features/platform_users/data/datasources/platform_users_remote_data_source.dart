import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/platform_users/data/models/platform_user_model.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_query.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_write_params.dart';

/// Raw `/users` calls — SUPER_ADMIN-only generic user directory.
class PlatformUsersRemoteDataSource {
  PlatformUsersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<PlatformUser>> list(PlatformUserQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, platformUserFromJson);
  }

  Future<PlatformUser> create(CreatePlatformUserParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/users', data: params.toRequestBody());
    return platformUserFromJson(response.data!);
  }

  Future<PlatformUser> update(String id, UpdatePlatformUserParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/users/$id', data: params.toRequestBody());
    return platformUserFromJson(response.data!);
  }

  Future<PlatformUser> setActive(String id, bool isActive) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id/${isActive ? 'activate' : 'deactivate'}',
    );
    return platformUserFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/users/$id');
}
