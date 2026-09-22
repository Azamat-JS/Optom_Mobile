import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/usecases/list_products_usecase.dart';

class ProductsListState {
  const ProductsListState({
    required this.items,
    required this.query,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<Product> items;
  final ProductQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  ProductsListState copyWith({
    List<Product>? items,
    ProductQuery? query,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return ProductsListState(
      items: items ?? this.items,
      query: query ?? this.query,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Owns the product list's filter/pagination state. Screens read
/// [productsListProvider] and call [search]/[filterByCategory]/[loadMore]/
/// [refresh] — none of them talk to the use case directly, keeping the
/// paging/filter logic in one place.
class ProductsListNotifier extends AsyncNotifier<ProductsListState> {
  @override
  Future<ProductsListState> build() => _fetch(const ProductQuery());

  Future<ProductsListState> _fetch(ProductQuery query) async {
    final result = await getIt<ListProductsUseCase>().call(query);
    return result.fold(
      (page) => ProductsListState(items: page.data, query: query, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull?.query ?? const ProductQuery();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1)));
  }

  Future<void> search(String query) async {
    final current = state.valueOrNull?.query ?? const ProductQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1, search: query)));
  }

  Future<void> filterByCategory(String? categoryId) async {
    final current = state.valueOrNull?.query ?? const ProductQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(ProductQuery(page: 1, search: current.search, categoryId: categoryId)),
    );
  }

  Future<void> filterByActive(bool? isActive) async {
    final current = state.valueOrNull?.query ?? const ProductQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(
        ProductQuery(page: 1, search: current.search, categoryId: current.categoryId, isActive: isActive),
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextQuery = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListProductsUseCase>().call(nextQuery);
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

final productsListProvider = AsyncNotifierProvider<ProductsListNotifier, ProductsListState>(
  ProductsListNotifier.new,
);
