import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class GetTeamDebtUseCase {
  GetTeamDebtUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<AgentDebtDetail>> call(String leadId, String debtId) => _repository.teamDebt(leadId, debtId);
}
