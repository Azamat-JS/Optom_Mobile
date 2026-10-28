import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class CreateLeadAgentUseCase {
  CreateLeadAgentUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<AgentAccountUser>> call(CreateAgentAccountParams params) => _repository.createLead(params);
}
