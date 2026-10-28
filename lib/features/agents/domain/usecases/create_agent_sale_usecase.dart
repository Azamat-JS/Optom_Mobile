import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale_params.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class CreateAgentSaleUseCase {
  CreateAgentSaleUseCase(this._repository);

  final AgentsRepository _repository;

  Future<Result<AgentSaleDetail>> call(CreateAgentSaleParams params) => _repository.createSale(params);
}
