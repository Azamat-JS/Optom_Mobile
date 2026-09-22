import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/catalog/data/models/catalog_model.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_product.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_query.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';

/// Buyer-facing browsing — `/catalog/*` is a completely separate bounded
/// context from `/products` (the tenant's own inventory): this is always
/// someone else's active stock.
class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<CatalogSeller>> listSellers() async {
    final response = await _dio.get<List<dynamic>>('/catalog/sellers');
    return response.data!.map((e) => catalogSellerFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CatalogStore>> listStoresForSeller(String sellerId) async {
    final response = await _dio.get<List<dynamic>>('/catalog/sellers/$sellerId/stores');
    return response.data!.map((e) => catalogStoreFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaginatedResult<CatalogProduct>> listProducts(CatalogQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/catalog',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, catalogProductFromJson);
  }
}
