import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class RejectAgentReturnUseCase {
  RejectAgentReturnUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<void>> call(String id, {String? reason}) => _repository.rejectReturn(id, reason: reason);
}
