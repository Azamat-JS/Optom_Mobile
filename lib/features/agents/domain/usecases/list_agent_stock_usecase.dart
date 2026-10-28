import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class ListAgentStockUseCase {
  ListAgentStockUseCase(this._repository);

  final AgentsRepository _repository;

  Future<Result<PaginatedResult<AgentStockItem>>> call({String? search, int page = 1, int limit = 60}) => _repository.stock(search: search, page: page, limit: limit);
}
