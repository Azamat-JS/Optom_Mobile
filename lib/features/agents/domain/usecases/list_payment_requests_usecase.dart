import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class ListPaymentRequestsUseCase {
  ListPaymentRequestsUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<PaginatedResult<AgentPaymentRequest>>> call({int page = 1}) => _repository.paymentRequests(page: page);
}
