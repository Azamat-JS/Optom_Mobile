import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class CancelAgentReturnUseCase {
  CancelAgentReturnUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<void>> call(String id) => _repository.cancelReturn(id);
}
