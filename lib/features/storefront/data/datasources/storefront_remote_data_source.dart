import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/storefront/data/models/storefront_model.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_query.dart';

/// Raw `/public/catalog/*` calls — guest-eligible, no auth header at all.
/// Takes the interceptor-free "bare" [Dio] instance (see `dio_client.dart`'s
/// `createBareDio()` doc comment, which already anticipated this feature).
class StorefrontRemoteDataSource {
  StorefrontRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<StorefrontCategory>> listCategories() async {
    final response = await _dio.get<List<dynamic>>('/public/catalog/categories');
    return response.data!.map((e) => storefrontCategoryFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaginatedResult<StorefrontProduct>> listProducts(StorefrontQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/public/catalog/products',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, storefrontProductFromJson);
  }

  Future<StorefrontProduct> getProduct(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/public/catalog/products/$id');
    return storefrontProductFromJson(response.data!);
  }
}
