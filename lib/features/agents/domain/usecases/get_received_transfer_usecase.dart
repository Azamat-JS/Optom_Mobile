import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class GetReceivedTransferUseCase {
  GetReceivedTransferUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<AgentTransferDetail>> call(String id) => _repository.transfer(id);
}
