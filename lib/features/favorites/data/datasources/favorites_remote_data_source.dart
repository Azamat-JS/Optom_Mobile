import 'package:dio/dio.dart';

import 'package:bsmart/features/favorites/data/models/favorite_model.dart';
import 'package:bsmart/features/favorites/domain/entities/favorite_product.dart';

/// Raw `/favorites/*` calls — authenticated, `CUSTOMER`/`RETAILER` only per
/// `favorite.controller.ts`'s `@Roles()`. Only ever reached post-login in
/// this app (Favorites tab shows a login prompt for a guest instead).
class FavoritesRemoteDataSource {
  FavoritesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<bool> toggle(String productId) async {
    final response = await _dio.post<Map<String, dynamic>>('/favorites/toggle/$productId');
    return response.data!['favorited'] as bool;
  }

  Future<List<FavoriteProduct>> list() async {
    final response = await _dio.get<List<dynamic>>('/favorites');
    return response.data!.map((e) => favoriteProductFromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> listIds() async {
    final response = await _dio.get<List<dynamic>>('/favorites/ids');
    return response.data!.cast<String>();
  }
}
