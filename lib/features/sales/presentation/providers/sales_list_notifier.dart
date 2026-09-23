import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_query.dart';
import 'package:bsmart/features/sales/domain/usecases/list_sales_usecase.dart';

class SalesListState {
  const SalesListState({
    required this.items,
    required this.query,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<Sale> items;
  final SaleQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  SalesListState copyWith({List<Sale>? items, SaleQuery? query, bool? hasNext, bool? isLoadingMore}) {
    return SalesListState(
      items: items ?? this.items,
      query: query ?? this.query,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SalesListNotifier extends AsyncNotifier<SalesListState> {
  @override
  Future<SalesListState> build() => _fetch(const SaleQuery());

  Future<SalesListState> _fetch(SaleQuery query) async {
    final result = await getIt<ListSalesUseCase>().call(query);
    return result.fold(
      (page) => SalesListState(items: page.data, query: query, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull?.query ?? const SaleQuery();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextQuery = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListSalesUseCase>().call(nextQuery);
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

final salesListProvider = AsyncNotifierProvider<SalesListNotifier, SalesListState>(SalesListNotifier.new);
