import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/favorites/domain/entities/favorite_product.dart';

abstract class FavoritesRepository {
  Future<Result<bool>> toggle(String productId);

  Future<Result<List<FavoriteProduct>>> list();

  Future<Result<List<String>>> listIds();
}
