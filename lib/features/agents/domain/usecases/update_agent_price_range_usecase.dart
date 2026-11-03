import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class UpdateAgentPriceRangeUseCase {
  UpdateAgentPriceRangeUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<void>> call(
    String leadId,
    String agentProductId, {
    required double price,
    required double discountPercent,
  }) => _repository.updatePriceRange(leadId, agentProductId, price: price, discountPercent: discountPercent);
}
