import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class UpdateLeadAgentUseCase {
  UpdateLeadAgentUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<AgentAccountUser>> call(String id, UpdateAgentAccountParams params) =>
      _repository.updateLead(id, params);
}
