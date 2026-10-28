import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class SetAgentStaffActiveUseCase {
  SetAgentStaffActiveUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<void>> call(String id, bool isActive) => _repository.setStaffActive(id, isActive);
}
