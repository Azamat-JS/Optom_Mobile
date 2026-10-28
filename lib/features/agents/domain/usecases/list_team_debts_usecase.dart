import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ListTeamDebtsUseCase {
  ListTeamDebtsUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<AgentDebtsPage>> call(String leadId, {bool openOnly = true, int page = 1}) =>
      _repository.teamDebts(leadId, openOnly: openOnly, page: page);
}
