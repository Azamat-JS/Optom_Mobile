import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_query.dart';
import 'package:bsmart/features/customers/domain/usecases/deactivate_customer_usecase.dart';
import 'package:bsmart/features/customers/domain/usecases/list_customers_usecase.dart';

class CustomersListState {
  const CustomersListState({
    required this.items,
    required this.query,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<Customer> items;
  final CustomerQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  CustomersListState copyWith({List<Customer>? items, CustomerQuery? query, bool? hasNext, bool? isLoadingMore}) {
    return CustomersListState(
      items: items ?? this.items,
      query: query ?? this.query,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CustomersListNotifier extends AsyncNotifier<CustomersListState> {
  @override
  Future<CustomersListState> build() => _fetch(const CustomerQuery());

  Future<CustomersListState> _fetch(CustomerQuery query) async {
    final result = await getIt<ListCustomersUseCase>().call(query);
    return result.fold(
      (page) => CustomersListState(items: page.data, query: query, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull?.query ?? const CustomerQuery();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1)));
  }

  Future<void> search(String query) async {
    final current = state.valueOrNull?.query ?? const CustomerQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1, search: query)));
  }

  Future<void> deactivate(String id) async {
    final result = await getIt<DeactivateCustomerUseCase>().call(id);
    result.fold((updated) {
      final current = state.valueOrNull;
      if (current == null) return;
      state = AsyncData(
        current.copyWith(items: [for (final c in current.items) if (c.id == id) updated else c]),
      );
    }, (failure) => throw failure);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextQuery = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListCustomersUseCase>().call(nextQuery);
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

final customersListProvider = AsyncNotifierProvider<CustomersListNotifier, CustomersListState>(
  CustomersListNotifier.new,
);
