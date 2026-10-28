import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ListLeadPaymentsUseCase {
  ListLeadPaymentsUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<PaginatedResult<AgentPaymentRequest>>> call(String leadId, {int page = 1}) =>
      _repository.payments(leadId, page: page);
}
