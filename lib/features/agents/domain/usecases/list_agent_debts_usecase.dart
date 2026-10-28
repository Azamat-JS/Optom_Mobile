import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class ListAgentDebtsUseCase {
  ListAgentDebtsUseCase(this._repository);

  final AgentsRepository _repository;

  Future<Result<AgentDebtsPage>> call({bool openOnly = true, String? search, int page = 1}) =>
      _repository.debts(openOnly: openOnly, search: search, page: page);
}
