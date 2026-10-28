import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ListLeadAgentsUseCase {
  ListLeadAgentsUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<PaginatedResult<AgentAccountUser>>> call({String? search}) => _repository.leads(search: search);
}
