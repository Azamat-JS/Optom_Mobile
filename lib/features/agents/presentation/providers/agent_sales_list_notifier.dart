import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/usecases/list_agent_sales_usecase.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

class AgentSalesListState {
  const AgentSalesListState({
    required this.items,
    required this.page,
    this.search = '',
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<AgentSale> items;
  final int page;
  final String search;
  final bool hasNext;
  final bool isLoadingMore;

  AgentSalesListState copyWith({List<AgentSale>? items, int? page, bool? hasNext, bool? isLoadingMore}) =>
      AgentSalesListState(
        items: items ?? this.items,
        page: page ?? this.page,
        search: search,
        hasNext: hasNext ?? this.hasNext,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// A lead agent's whole team's sales, or a staff agent's own (scoped server-side).
class AgentSalesListNotifier extends AsyncNotifier<AgentSalesListState> {
  @override
  Future<AgentSalesListState> build() {
    ref.watch(currentUserIdProvider);
    return _fetch('');
  }

  Future<AgentSalesListState> _fetch(String search) async {
    final result = await getIt<ListAgentSalesUseCase>().call(search: search);
    return result.fold(
      (page) => AgentSalesListState(items: page.data, page: 1, search: search, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> search(String text) async {
    state = await AsyncValue.guard(() => _fetch(text.trim()));
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetch(state.valueOrNull?.search ?? ''));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<ListAgentSalesUseCase>().call(search: current.search, page: current.page + 1);
    state = result.fold(
      (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.data],
          page: current.page + 1,
          hasNext: page.meta.hasNext,
          isLoadingMore: false,
        ),
      ),
      (_) => AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }
}

final agentSalesListProvider =
    AsyncNotifierProvider<AgentSalesListNotifier, AgentSalesListState>(AgentSalesListNotifier.new);
