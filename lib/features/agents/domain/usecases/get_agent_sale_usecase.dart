import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class GetAgentSaleUseCase {
  GetAgentSaleUseCase(this._repository);

  final AgentsRepository _repository;

  Future<Result<AgentSaleDetail>> call(String id) => _repository.sale(id);
}
