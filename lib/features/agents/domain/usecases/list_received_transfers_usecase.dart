import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class ListReceivedTransfersUseCase {
  ListReceivedTransfersUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<PaginatedResult<AgentTransfer>>> call({int page = 1}) => _repository.transfers(page: page);
}
