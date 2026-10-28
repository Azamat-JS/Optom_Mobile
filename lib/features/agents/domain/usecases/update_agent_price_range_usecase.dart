import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class UpdateAgentPriceRangeUseCase {
  UpdateAgentPriceRangeUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<void>> call(String leadId, String agentProductId, {required double min, required double max}) =>
      _repository.updatePriceRange(leadId, agentProductId, min: min, max: max);
}
