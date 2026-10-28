import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class PayAgentDebtUseCase {
  PayAgentDebtUseCase(this._repository);

  final AgentsRepository _repository;

  Future<Result<AgentDebtDetail>> call(String id, {required double amount, String? notes}) => _repository.payDebt(id, amount: amount, notes: notes);
}
