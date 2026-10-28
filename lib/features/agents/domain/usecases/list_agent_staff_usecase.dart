import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class ListAgentStaffUseCase {
  ListAgentStaffUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<PaginatedResult<AgentAccountUser>>> call({String? search}) => _repository.staff(search: search);
}
