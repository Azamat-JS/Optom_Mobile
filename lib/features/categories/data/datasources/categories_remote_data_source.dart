import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/categories/data/models/category_model.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/domain/entities/category_query.dart';
import 'package:bsmart/features/categories/domain/entities/category_write_params.dart';

class CategoriesRemoteDataSource {
  CategoriesRemoteDataSource(this._dio);

  final Dio _dio;

  /// Root categories only (`parentId=root`), each with its direct
  /// [Category.children] already embedded — one request gets the full
  /// 2-level tree, matching the backend's max-depth invariant.
  Future<PaginatedResult<Category>> getRootCategories({
    String? search,
    bool? isActive,
    int limit = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/categories',
      queryParameters: {
        'parentId': 'root',
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        'isActive': ?isActive,
      },
    );
    return PaginatedResult.fromJson(response.data!, categoryFromJson);
  }

  /// Flat (non-tree) admin-management list — SUPER_ADMIN only.
  Future<PaginatedResult<Category>> list(CategoryQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/categories',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, categoryFromJson);
  }

  Future<Category> create(CreateCategoryParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/categories', data: params.toRequestBody());
    return categoryFromJson(response.data!);
  }

  Future<Category> update(String id, UpdateCategoryParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/categories/$id', data: params.toRequestBody());
    return categoryFromJson(response.data!);
  }

  Future<Category> uploadImage(String id, {required String filePath}) async {
    final formData = FormData.fromMap({'image': await MultipartFile.fromFile(filePath)});
    final response = await _dio.post<Map<String, dynamic>>('/categories/$id/image', data: formData);
    return categoryFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/categories/$id');
}
