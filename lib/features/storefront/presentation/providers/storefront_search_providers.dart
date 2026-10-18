import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_query.dart';
import 'package:bsmart/features/storefront/domain/usecases/browse_storefront_usecase.dart';

/// The last searches on this device (newest first) — plain
/// SharedPreferences like the language choice; not tied to an account.
class RecentSearchesNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'bsmart.storefront.recentSearches';
  static const maxEntries = 8;

  @override
  Future<List<String>> build() async => (await SharedPreferences.getInstance()).getStringList(_key) ?? const [];

  /// Moves [term] to the front (case-insensitive de-dup), capped at [maxEntries].
  Future<void> add(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    // Wait for the saved list: adding before it loaded would overwrite it.
    final current = await future;
    final next = [trimmed, ...current.where((t) => t.toLowerCase() != trimmed.toLowerCase())].take(maxEntries).toList();
    state = AsyncData(next);
    await (await SharedPreferences.getInstance()).setStringList(_key, next);
  }

  Future<void> clear() async {
    state = const AsyncData([]);
    await (await SharedPreferences.getInstance()).remove(_key);
  }
}

final recentSearchesProvider = AsyncNotifierProvider<RecentSearchesNotifier, List<String>>(RecentSearchesNotifier.new);

/// Live suggestions while typing: the first matches for the text so far.
/// One cached entry per typed text, so a late answer for an older text can
/// never overwrite a newer one.
final storefrontSuggestionsProvider = FutureProvider.autoDispose.family<List<StorefrontProduct>, String>((
  ref,
  text,
) async {
  final result = await getIt<BrowseStorefrontUseCase>().call(StorefrontQuery(search: text, limit: 12));
  return result.fold((page) => page.data, (failure) => throw failure);
});

class StorefrontSearchResults {
  const StorefrontSearchResults({
    required this.query,
    required this.items,
    required this.total,
    required this.hasNext,
    this.isLoadingMore = false,
  });

  final StorefrontQuery query;
  final List<StorefrontProduct> items;
  final int total;
  final bool hasNext;
  final bool isLoadingMore;

  StorefrontSearchResults copyWith({
    StorefrontQuery? query,
    List<StorefrontProduct>? items,
    int? total,
    bool? hasNext,
    bool? isLoadingMore,
  }) => StorefrontSearchResults(
    query: query ?? this.query,
    items: items ?? this.items,
    total: total ?? this.total,
    hasNext: hasNext ?? this.hasNext,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Results for a submitted search. Pages are large (the API maximum) because
/// sorting and the in-stock / category chips are applied on the device, to
/// what has been loaded — the public catalog has no sort parameter.
///
/// `null` state = nothing submitted yet.
class StorefrontSearchResultsNotifier extends AutoDisposeAsyncNotifier<StorefrontSearchResults?> {
  static const pageSize = 100;

  /// Bumped by every submit/reset, so an answer to a replaced request is dropped.
  int _generation = 0;

  @override
  Future<StorefrontSearchResults?> build() async => null;

  Future<void> submit(String text, {String? categoryId}) async {
    final generation = ++_generation;
    final query = StorefrontQuery(search: text.trim(), categoryId: categoryId, limit: pageSize);
    state = const AsyncLoading();
    final result = await getIt<BrowseStorefrontUseCase>().call(query);
    if (generation != _generation) return;
    state = result.fold(
      (page) => AsyncData(
        StorefrontSearchResults(query: query, items: page.data, total: page.meta.total, hasNext: page.meta.hasNext),
      ),
      (failure) => AsyncError(failure, StackTrace.current),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    final generation = _generation;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final next = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<BrowseStorefrontUseCase>().call(next);
    if (generation != _generation) return;
    state = AsyncData(
      result.fold(
        (page) => current.copyWith(
          query: next,
          items: [...current.items, ...page.data],
          total: page.meta.total,
          hasNext: page.meta.hasNext,
          isLoadingMore: false,
        ),
        (_) => current.copyWith(isLoadingMore: false),
      ),
    );
  }

  /// Back to the "type a search" state.
  void reset() {
    _generation++;
    state = const AsyncData(null);
  }
}

final storefrontSearchResultsProvider =
    AsyncNotifierProvider.autoDispose<StorefrontSearchResultsNotifier, StorefrontSearchResults?>(
      StorefrontSearchResultsNotifier.new,
    );
