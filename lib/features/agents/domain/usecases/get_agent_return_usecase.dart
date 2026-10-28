import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class GetAgentReturnUseCase {
  GetAgentReturnUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<AgentReturnDetail>> call(String id) => _repository.returnDetail(id);
}
