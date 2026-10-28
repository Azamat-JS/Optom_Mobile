import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class ListAgentSalesUseCase {
  ListAgentSalesUseCase(this._repository);

  final AgentsRepository _repository;

  Future<Result<PaginatedResult<AgentSale>>> call({String? search, int page = 1}) => _repository.sales(search: search, page: page);
}
