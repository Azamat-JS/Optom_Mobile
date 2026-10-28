import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class ListAgentReturnsUseCase {
  ListAgentReturnsUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<PaginatedResult<AgentReturn>>> call({int page = 1}) => _repository.returns(page: page);
}
