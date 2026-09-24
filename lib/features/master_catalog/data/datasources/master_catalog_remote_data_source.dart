import 'package:dio/dio.dart';

import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/master_catalog/data/models/master_product_model.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product_write_params.dart';

/// SELLER/RETAILER only ever see `APPROVED` entries here regardless of
/// `status`/query params (enforced server-side) — the moderation-only calls
/// below (`create`/`update`/`approve`/`reject`/`delete`/image management)
/// 403 for anyone but SUPER_ADMIN, matching `master-product.controller.ts`.
class MasterCatalogRemoteDataSource {
  MasterCatalogRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<MasterProduct>> search({
    String? search,
    String? categoryId,
    String? barcode,
    MasterProductStatus? status,
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
        if (status != null) 'status': status.toWire(),
      },
    );
    return PaginatedResult.fromJson(response.data!, masterProductFromJson);
  }

  Future<MasterProduct> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/master-products/$id');
    return masterProductFromJson(response.data!);
  }

  Future<MasterProduct> create(CreateMasterProductParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/master-products', data: params.toRequestBody());
    return masterProductFromJson(response.data!);
  }

  Future<MasterProduct> update(String id, UpdateMasterProductParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/master-products/$id', data: params.toRequestBody());
    return masterProductFromJson(response.data!);
  }

  Future<MasterProduct> approve(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>('/master-products/$id/approve');
    return masterProductFromJson(response.data!);
  }

  Future<MasterProduct> reject(String id, {String? reason}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/master-products/$id/reject',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
    return masterProductFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/master-products/$id');

  /// Returns just the created image row (`MasterProductImage`, not the full
  /// `MasterProduct` — confirmed against `master-product.service.ts
  /// uploadImage()`'s `prisma.masterProductImage.create()` return value) —
  /// callers re-fetch via [getById] afterward, same as
  /// `ProductDetailScreen._addImage()`'s pattern for the regular product
  /// image endpoint.
  Future<MasterProductImageRef> uploadImage(String id, {required String filePath, bool isPrimary = false}) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
      'isPrimary': isPrimary,
    });
    final response = await _dio.post<Map<String, dynamic>>('/master-products/$id/images', data: formData);
    final json = response.data!;
    return MasterProductImageRef(
      id: json['id'] as String,
      url: json['url'] as String,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  Future<void> removeImage(String id, String imageId) =>
      _dio.delete<void>('/master-products/$id/images/$imageId');
}
