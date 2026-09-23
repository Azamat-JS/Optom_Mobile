import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/favorites/domain/repositories/favorites_repository.dart';

class ToggleFavoriteUseCase {
  ToggleFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<Result<bool>> call(String productId) => _repository.toggle(productId);
}
