import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/usecases/list_agent_debts_usecase.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

class AgentDebtsListState {
  const AgentDebtsListState({
    required this.items,
    required this.totalBalance,
    required this.page,
    this.openOnly = true,
    this.search = '',
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<AgentDebt> items;

  /// Outstanding total of the whole filtered list (not just the loaded pages), per currency.
  final MoneyByCurrency totalBalance;
  final int page;
  final bool openOnly;
  final String search;
  final bool hasNext;
  final bool isLoadingMore;

  AgentDebtsListState copyWith({List<AgentDebt>? items, int? page, bool? hasNext, bool? isLoadingMore}) =>
      AgentDebtsListState(
        items: items ?? this.items,
        totalBalance: totalBalance,
        page: page ?? this.page,
        openOnly: openOnly,
        search: search,
        hasNext: hasNext ?? this.hasNext,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// Customer debts from agent sales: a lead agent's whole team, or a staff agent's own.
class AgentDebtsListNotifier extends AsyncNotifier<AgentDebtsListState> {
  @override
  Future<AgentDebtsListState> build() {
    ref.watch(currentUserIdProvider);
    return _fetch(openOnly: true, search: '');
  }

  Future<AgentDebtsListState> _fetch({required bool openOnly, required String search}) async {
    final result = await getIt<ListAgentDebtsUseCase>().call(openOnly: openOnly, search: search);
    return result.fold(
      (page) => AgentDebtsListState(
        items: page.items,
        totalBalance: page.totalBalance,
        page: 1,
        openOnly: openOnly,
        search: search,
        hasNext: page.hasNext,
      ),
      (failure) => throw failure,
    );
  }

  Future<void> setOpenOnly(bool openOnly) async {
    final search = state.valueOrNull?.search ?? '';
    state = await AsyncValue.guard(() => _fetch(openOnly: openOnly, search: search));
  }

  Future<void> search(String text) async {
    final openOnly = state.valueOrNull?.openOnly ?? true;
    state = await AsyncValue.guard(() => _fetch(openOnly: openOnly, search: text.trim()));
  }

  Future<void> refresh() async {
    final current = state.valueOrNull;
    state = await AsyncValue.guard(
      () => _fetch(openOnly: current?.openOnly ?? true, search: current?.search ?? ''),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<ListAgentDebtsUseCase>().call(
      openOnly: current.openOnly,
      search: current.search,
      page: current.page + 1,
    );
    state = result.fold(
      (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          page: current.page + 1,
          hasNext: page.hasNext,
          isLoadingMore: false,
        ),
      ),
      (_) => AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }
}

final agentDebtsListProvider =
    AsyncNotifierProvider<AgentDebtsListNotifier, AgentDebtsListState>(AgentDebtsListNotifier.new);
