import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class GetAgentProfitUseCase {
  GetAgentProfitUseCase(this._repository);

  final AgentsRepository _repository;

  Future<Result<AgentProfit>> call(AgentProfitPeriod period) => _repository.profit(period);
}
