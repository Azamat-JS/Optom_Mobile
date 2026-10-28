import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class GetLeadAgentSummaryUseCase {
  GetLeadAgentSummaryUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<LeadAgentSummary>> call(String id) => _repository.leadSummary(id);
}
