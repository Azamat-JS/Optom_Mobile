import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class CreateAgentStaffUseCase {
  CreateAgentStaffUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<AgentAccountUser>> call(CreateAgentAccountParams params) => _repository.createStaff(params);
}
