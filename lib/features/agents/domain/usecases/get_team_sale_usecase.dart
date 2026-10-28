import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class GetTeamSaleUseCase {
  GetTeamSaleUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<AgentSaleDetail>> call(String leadId, String saleId) => _repository.teamSale(leadId, saleId);
}
