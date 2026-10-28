import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class CreateAgentTransferUseCase {
  CreateAgentTransferUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<AgentTransferDetail>> call(CreateAgentTransferParams params) => _repository.createTransfer(params);
}
