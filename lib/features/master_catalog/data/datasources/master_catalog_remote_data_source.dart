import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/master_catalog/data/models/master_product_model.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';

/// Read-only for Phase 1 — moderation (`approve`/`reject`/create/delete) is
/// SUPER_ADMIN-only, Phase 3 scope. SELLER/RETAILER only ever see `APPROVED`
/// entries here regardless of query params (enforced server-side).
class MasterCatalogRemoteDataSource {
  MasterCatalogRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<MasterProduct>> search({
    String? search,
    String? categoryId,
    String? barcode,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/master-products',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        'categoryId': ?categoryId,
        'barcode': ?barcode,
      },
    );
    return PaginatedResult.fromJson(response.data!, masterProductFromJson);
  }

  Future<MasterProduct> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/master-products/$id');
    return masterProductFromJson(response.data!);
  }
}
