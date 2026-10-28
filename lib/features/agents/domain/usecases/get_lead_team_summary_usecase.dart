import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class GetLeadTeamSummaryUseCase {
  GetLeadTeamSummaryUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<AgentSummary>> call(String leadId) => _repository.teamSummary(leadId);
}
