import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class UpdateAgentTransferSalaryUseCase {
  UpdateAgentTransferSalaryUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<AgentTransferDetail>> call(String transferId, double salaryPercent) =>
      _repository.updateTransferSalary(transferId, salaryPercent);
}
