import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/favorites/domain/usecases/list_favorite_ids_usecase.dart';
import 'package:bsmart/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:bsmart/features/favorites/presentation/providers/favorites_list_notifier.dart';

/// Just the set of favorited product ids — powers the heart icon on the
/// product-detail screen without needing the full `FavoriteProduct` list.
/// Built lazily (only fetched once something actually watches it, i.e. once
/// a logged-in customer opens a product) rather than eagerly on login.
class FavoriteIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final result = await getIt<ListFavoriteIdsUseCase>().call();
    return result.fold((ids) => ids.toSet(), (failure) => throw failure);
  }

  Future<void> toggle(String productId) async {
    final current = state.valueOrNull ?? const {};
    // Optimistic — flips immediately, reconciled against the server's own
    // `favorited` boolean once the call resolves (network failure reverts).
    final optimistic = Set<String>.from(current);
    final wasFavorited = optimistic.contains(productId);
    wasFavorited ? optimistic.remove(productId) : optimistic.add(productId);
    state = AsyncData(optimistic);

    final result = await getIt<ToggleFavoriteUseCase>().call(productId);
    result.fold(
      (favorited) {
        final reconciled = Set<String>.from(state.valueOrNull ?? const {});
        favorited ? reconciled.add(productId) : reconciled.remove(productId);
        state = AsyncData(reconciled);
        // This id set and the Sevimlilar tab's own `favoritesListProvider`
        // are two independently-fetched providers with no shared cache —
        // without this, toggling a favorite here (product detail) never
        // shows up on/disappears from that list until something else
        // happens to invalidate it (caught live: a freshly favorited
        // product didn't appear in "Sevimlilar" until a manual refresh).
        ref.invalidate(favoritesListProvider);
      },
      (failure) => state = AsyncData(current),
    );
  }
}

final favoriteIdsProvider = AsyncNotifierProvider<FavoriteIdsNotifier, Set<String>>(FavoriteIdsNotifier.new);
