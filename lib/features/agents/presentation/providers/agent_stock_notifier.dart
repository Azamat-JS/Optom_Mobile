import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/usecases/list_agent_stock_usecase.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

class AgentStockState {
  const AgentStockState({required this.items, required this.search});

  final List<AgentStockItem> items;
  final String search;
}

/// The lead agent's in-stock products (shared with its staff agents) — what the Sell tab shows.
/// Agents hold a modest assortment, so one page of 60 covers a search without "load more".
class AgentStockNotifier extends AsyncNotifier<AgentStockState> {
  @override
  Future<AgentStockState> build() {
    ref.watch(currentUserIdProvider);
    return _fetch('');
  }

  Future<AgentStockState> _fetch(String search) async {
    final result = await getIt<ListAgentStockUseCase>().call(search: search);
    return result.fold(
      (page) => AgentStockState(items: page.data, search: search),
      (failure) => throw failure,
    );
  }

  Future<void> search(String text) async {
    state = await AsyncValue.guard(() => _fetch(text.trim()));
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _fetch(state.valueOrNull?.search ?? ''));
  }
}

final agentStockProvider = AsyncNotifierProvider<AgentStockNotifier, AgentStockState>(AgentStockNotifier.new);
