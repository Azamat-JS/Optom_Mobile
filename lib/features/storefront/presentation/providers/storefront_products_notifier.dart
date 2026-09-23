import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_query.dart';
import 'package:bsmart/features/storefront/domain/usecases/browse_storefront_usecase.dart';

class StorefrontProductsState {
  const StorefrontProductsState({
    required this.items,
    required this.query,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<StorefrontProduct> items;
  final StorefrontQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  StorefrontProductsState copyWith({
    List<StorefrontProduct>? items,
    StorefrontQuery? query,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return StorefrontProductsState(
      items: items ?? this.items,
      query: query ?? this.query,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// The storefront's product feed — a flat, filterable list (category chips +
/// search) rather than the B2B catalog's seller-first browse, since a
/// customer storefront reads as one marketplace, not "pick a wholesaler
/// first" (see `CLAUDE.md`'s Phase 2 notes).
class StorefrontProductsNotifier extends AsyncNotifier<StorefrontProductsState> {
  @override
  Future<StorefrontProductsState> build() => _fetch(const StorefrontQuery());

  Future<StorefrontProductsState> _fetch(StorefrontQuery query) async {
    final result = await getIt<BrowseStorefrontUseCase>().call(query);
    return result.fold(
      (page) => StorefrontProductsState(items: page.data, query: query, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull?.query ?? const StorefrontQuery();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1)));
  }

  Future<void> search(String query) async {
    final current = state.valueOrNull?.query ?? const StorefrontQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(page: 1, search: query, clearSearch: query.isEmpty)),
    );
  }

  Future<void> filterByCategory(String? categoryId) async {
    final current = state.valueOrNull?.query ?? const StorefrontQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(page: 1, categoryId: categoryId, clearCategory: categoryId == null)),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextQuery = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<BrowseStorefrontUseCase>().call(nextQuery);
    state = result.fold(
      (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.data],
          query: nextQuery,
          hasNext: page.meta.hasNext,
          isLoadingMore: false,
        ),
      ),
      (failure) => AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }
}

final storefrontProductsProvider = AsyncNotifierProvider<StorefrontProductsNotifier, StorefrontProductsState>(
  StorefrontProductsNotifier.new,
);
