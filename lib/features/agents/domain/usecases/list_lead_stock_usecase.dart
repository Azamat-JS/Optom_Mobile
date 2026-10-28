import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ListLeadStockUseCase {
  ListLeadStockUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<PaginatedResult<AgentStockItem>>> call(String leadId, {int page = 1}) =>
      _repository.leadStock(leadId, page: page);
}
