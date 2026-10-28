import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ListLeadReturnsUseCase {
  ListLeadReturnsUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<PaginatedResult<AgentReturn>>> call(String leadId, {int page = 1}) =>
      _repository.returns(leadId, page: page);
}
