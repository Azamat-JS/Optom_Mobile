import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ListTeamSalesUseCase {
  ListTeamSalesUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<PaginatedResult<AgentSale>>> call(String leadId, {int page = 1}) =>
      _repository.teamSales(leadId, page: page);
}
