import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/expenditure_type.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_query.dart';
import 'package:bsmart/features/expenditures/domain/usecases/delete_expenditure_usecase.dart';
import 'package:bsmart/features/expenditures/domain/usecases/list_expenditures_usecase.dart';

class ExpendituresListState {
  const ExpendituresListState({
    required this.items,
    required this.query,
    required this.totalAmount,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<Expenditure> items;
  final ExpenditureQuery query;
  final double totalAmount;
  final bool hasNext;
  final bool isLoadingMore;

  ExpendituresListState copyWith({
    List<Expenditure>? items,
    ExpenditureQuery? query,
    double? totalAmount,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return ExpendituresListState(
      items: items ?? this.items,
      query: query ?? this.query,
      totalAmount: totalAmount ?? this.totalAmount,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ExpendituresListNotifier extends AsyncNotifier<ExpendituresListState> {
  @override
  Future<ExpendituresListState> build() => _fetch(const ExpenditureQuery());

  Future<ExpendituresListState> _fetch(ExpenditureQuery query) async {
    final result = await getIt<ListExpendituresUseCase>().call(query);
    return result.fold(
      (page) => ExpendituresListState(
        items: page.data,
        query: query,
        totalAmount: page.totalAmount,
        hasNext: page.hasNext,
      ),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull?.query ?? const ExpenditureQuery();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1)));
  }

  Future<void> setTypeFilter(ExpenditureType? type) async {
    final current = state.valueOrNull?.query ?? const ExpenditureQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(page: 1, type: type, clearType: type == null)),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextQuery = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListExpendituresUseCase>().call(nextQuery);
    state = result.fold(
      (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.data],
          query: nextQuery,
          totalAmount: page.totalAmount,
          hasNext: page.hasNext,
          isLoadingMore: false,
        ),
      ),
      (failure) => AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }

  Future<void> delete(String id) async {
    final result = await getIt<DeleteExpenditureUseCase>().call(id);
    // Must await refresh() here, not fire-and-forget it — otherwise a
    // setTypeFilter()/refresh() call made shortly after this one returns can
    // race it, and whichever fetch's response lands last silently overwrites
    // the other's (real bug caught live: deleting a row while filtered, then
    // immediately switching the filter back to "Barchasi", showed an empty
    // list because this trailing fetch clobbered the correct one).
    await result.fold((_) => refresh(), (failure) => Future<void>.error(failure));
  }
}

final expendituresListProvider = AsyncNotifierProvider<ExpendituresListNotifier, ExpendituresListState>(
  ExpendituresListNotifier.new,
);
