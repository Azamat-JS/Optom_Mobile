import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class SendAgentReturnUseCase {
  SendAgentReturnUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<AgentReturnDetail>> call(List<AgentReturnLineParams> lines, {String? notes}) =>
      _repository.sendReturn(lines, notes: notes);
}
