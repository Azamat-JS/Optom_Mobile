import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/categories/data/models/category_model.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';

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
}
