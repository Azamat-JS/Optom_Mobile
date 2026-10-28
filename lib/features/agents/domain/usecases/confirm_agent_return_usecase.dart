import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ConfirmAgentReturnUseCase {
  ConfirmAgentReturnUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<void>> call(String id) => _repository.confirmReturn(id);
}
