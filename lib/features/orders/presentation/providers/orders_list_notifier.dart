import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_query.dart';
import 'package:bsmart/features/orders/domain/usecases/list_orders_usecase.dart';

class OrdersListState {
  const OrdersListState({required this.items, required this.query, this.hasNext = false, this.isLoadingMore = false});

  final List<Order> items;
  final OrderQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  OrdersListState copyWith({List<Order>? items, OrderQuery? query, bool? hasNext, bool? isLoadingMore}) {
    return OrdersListState(
      items: items ?? this.items,
      query: query ?? this.query,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Defaults to no `view` param — the backend's default scoping already
/// gives a SELLER their incoming B2B orders and a RETAILER their own
/// outgoing B2B orders. [setView] lets a RETAILER additionally switch to
/// their incoming B2C orders from customers (see `OrderQuery`'s doc
/// comment).
class OrdersListNotifier extends AsyncNotifier<OrdersListState> {
  @override
  Future<OrdersListState> build() => _fetch(const OrderQuery());

  Future<OrdersListState> _fetch(OrderQuery query) async {
    final result = await getIt<ListOrdersUseCase>().call(query);
    return result.fold(
      (page) => OrdersListState(items: page.data, query: query, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull?.query ?? const OrderQuery();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1)));
  }

  Future<void> filterByStatus(OrderStatus? status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(OrderQuery(status: status, page: 1)),
    );
  }

  /// RETAILER-only toggle (see `OrderQuery.view`'s doc comment) — `null`
  /// shows their own outgoing B2B orders, `'incoming'` their incoming B2C
  /// orders from customers. Resets status filter/page, same as
  /// [filterByStatus], since it's effectively a different list.
  Future<void> setView(String? view) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(OrderQuery(view: view, page: 1)),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextQuery = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListOrdersUseCase>().call(nextQuery);
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

final ordersListProvider = AsyncNotifierProvider<OrdersListNotifier, OrdersListState>(
  OrdersListNotifier.new,
);
