import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class GetAgentDebtUseCase {
  GetAgentDebtUseCase(this._repository);

  final AgentsRepository _repository;

  Future<Result<AgentDebtDetail>> call(String id) => _repository.debt(id);
}
