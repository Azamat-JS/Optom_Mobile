import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/favorites/domain/entities/favorite_product.dart';
import 'package:bsmart/features/favorites/domain/repositories/favorites_repository.dart';

class ListFavoritesUseCase {
  ListFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<Result<List<FavoriteProduct>>> call() => _repository.list();
}
