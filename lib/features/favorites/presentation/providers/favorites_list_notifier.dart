import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/favorites/domain/entities/favorite_product.dart';
import 'package:bsmart/features/favorites/domain/usecases/list_favorites_usecase.dart';

class FavoritesListNotifier extends AsyncNotifier<List<FavoriteProduct>> {
  @override
  Future<List<FavoriteProduct>> build() async {
    final result = await getIt<ListFavoritesUseCase>().call();
    return result.fold((d) => d, (failure) => throw failure);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final favoritesListProvider = AsyncNotifierProvider<FavoritesListNotifier, List<FavoriteProduct>>(
  FavoritesListNotifier.new,
);
