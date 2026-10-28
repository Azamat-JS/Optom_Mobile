import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';
import 'package:bsmart/features/agents/domain/usecases/get_lead_agent_summary_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/get_lead_team_summary_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_lead_agents_usecase.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

// The business owner's agent screens (Phase 10 A7c). The roster is one page (owners have a
// handful of lead agents); one lead agent's figures are per-id families.

class LeadAgentsListNotifier extends AsyncNotifier<List<AgentAccountUser>> {
  @override
  Future<List<AgentAccountUser>> build() {
    ref.watch(currentUserIdProvider);
    return _fetch();
  }

  Future<List<AgentAccountUser>> _fetch() async {
    final result = await getIt<ListLeadAgentsUseCase>().call();
    return result.fold((page) => page.data, (failure) => throw failure);
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_fetch);
}

final leadAgentsListProvider = AsyncNotifierProvider<LeadAgentsListNotifier, List<AgentAccountUser>>(
  LeadAgentsListNotifier.new,
);

/// What the lead agent holds and owes the owner, and how many requests wait.
final leadAgentSummaryProvider = FutureProvider.autoDispose.family<LeadAgentSummary, String>((ref, id) async {
  final result = await getIt<GetLeadAgentSummaryUseCase>().call(id);
  return result.fold((summary) => summary, (failure) => throw failure);
});

/// The lead agent's team's sales today / 30 days and open customer debts (read-only, no cost).
final leadTeamSummaryProvider = FutureProvider.autoDispose.family<AgentSummary, String>((ref, id) async {
  final result = await getIt<GetLeadTeamSummaryUseCase>().call(id);
  return result.fold((summary) => summary, (failure) => throw failure);
});
