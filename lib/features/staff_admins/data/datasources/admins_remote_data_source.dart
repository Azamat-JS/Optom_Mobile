import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/staff_admins/data/models/admin_model.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_query.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_write_params.dart';

/// Raw `/admins` calls — panel-staff (`SELLER_ADMIN`/`RETAILER_ADMIN`) CRUD.
class AdminsRemoteDataSource {
  AdminsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Admin>> list(AdminQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admins',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, adminFromJson);
  }

  Future<Admin> create(CreateAdminParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/admins', data: params.toRequestBody());
    return adminFromJson(response.data!);
  }

  Future<Admin> update(String id, UpdateAdminParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/admins/$id', data: params.toRequestBody());
    return adminFromJson(response.data!);
  }

  Future<Admin> setActive(String id, bool isActive) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admins/$id/${isActive ? 'activate' : 'deactivate'}',
    );
    return adminFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/admins/$id');
}
