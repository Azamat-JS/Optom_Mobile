import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/favorites/domain/repositories/favorites_repository.dart';

class ListFavoriteIdsUseCase {
  ListFavoriteIdsUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<Result<List<String>>> call() => _repository.listIds();
}
