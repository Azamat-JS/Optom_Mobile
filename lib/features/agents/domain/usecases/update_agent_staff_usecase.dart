import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class UpdateAgentStaffUseCase {
  UpdateAgentStaffUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<AgentAccountUser>> call(String id, UpdateAgentAccountParams params) => _repository.updateStaff(id, params);
}
