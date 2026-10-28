import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ListLeadTransfersUseCase {
  ListLeadTransfersUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<PaginatedResult<AgentTransfer>>> call(String leadId, {int page = 1}) =>
      _repository.transfers(leadId, page: page);
}
