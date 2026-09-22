import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/products/data/models/product_model.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_image.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/entities/product_write_params.dart';

/// Raw `/products` (+ `/products/:id/images`) calls. **`GET /products` is
/// always scoped to the caller's own `sellerId`/store** — this is the
/// tenant's own inventory-management list, never a browsable market of other
/// sellers' stock (that's the separate, not-yet-built `catalog` module).
class ProductsRemoteDataSource {
  ProductsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Product>> list(ProductQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, productFromJson);
  }

  Future<Product> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/products/$id');
    return productFromJson(response.data!);
  }

  Future<Product> create(CreateProductParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/products', data: params.toRequestBody());
    return productFromJson(response.data!);
  }

  Future<Product> update(String id, UpdateProductParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/products/$id', data: params.toRequestBody());
    return productFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/products/$id');

  Future<Product> receiveStock(String id, ReceiveStockParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/products/$id/stock',
      data: params.toRequestBody(),
    );
    return productFromJson(response.data!);
  }

  Future<Product> assignBarcode(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/products/$id/barcode');
    return productFromJson(response.data!);
  }

  Future<void> shareToCatalog(String id) => _dio.post<void>('/products/$id/share-to-catalog');

  Future<String> nextPlu() async {
    final response = await _dio.get<Map<String, dynamic>>('/products/plu/next');
    return response.data!['plu'] as String;
  }

  Future<List<Product>> bestSelling({int limit = 18}) async {
    final response = await _dio.get<List<dynamic>>(
      '/products/best-selling',
      queryParameters: {'limit': limit},
    );
    return response.data!.map((e) => productFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductImage> uploadImage(
    String productId, {
    required String filePath,
    bool isPrimary = false,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
      'isPrimary': isPrimary,
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/products/$productId/images',
      data: formData,
    );
    return productImageFromJson(response.data!);
  }

  Future<void> deleteImage(String productId, String imageId) {
    return _dio.delete<void>('/products/$productId/images/$imageId');
  }
}
