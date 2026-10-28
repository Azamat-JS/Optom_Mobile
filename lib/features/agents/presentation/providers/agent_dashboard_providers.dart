import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/usecases/get_agent_profit_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/get_agent_summary_usecase.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';
import 'package:bsmart/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

class AgentSummaryNotifier extends AsyncNotifier<AgentSummary> {
  @override
  Future<AgentSummary> build() {
    ref.watch(currentUserIdProvider);
    return _fetch();
  }

  Future<AgentSummary> _fetch() async {
    final result = await getIt<GetAgentSummaryUseCase>().call();
    return result.fold((summary) => summary, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final agentSummaryProvider = AsyncNotifierProvider<AgentSummaryNotifier, AgentSummary>(AgentSummaryNotifier.new);

/// The agent's own profile from `GET /auth/me` — the login response has no `agentOwner`, so the
/// home screen fetches it to say who the agent works for.
final agentProfileProvider = FutureProvider.autoDispose<User>((ref) async {
  ref.watch(currentUserIdProvider);
  final result = await getIt<GetCurrentUserUseCase>().call();
  return result.fold((user) => user, (failure) => throw failure);
});

/// The lead agent's net profit for one window (staff agents get 403 server-side and never ask).
final agentProfitProvider = FutureProvider.autoDispose.family<AgentProfit, AgentProfitPeriod>((ref, period) async {
  ref.watch(currentUserIdProvider);
  final result = await getIt<GetAgentProfitUseCase>().call(period);
  return result.fold((profit) => profit, (failure) => throw failure);
});
