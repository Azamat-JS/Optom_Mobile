import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';

/// A lead agent's management screens: its account with the business owner (payments and returns
/// it sends), the transfers it received, and its staff agents. Owner-side decisions are A7c.
abstract class LeadAgentRepository {
  Future<Result<LeadAgentAccount>> account();

  Future<Result<PaginatedResult<AgentPaymentRequest>>> paymentRequests({int page = 1});

  Future<Result<AgentPaymentRequest>> sendPayment({required double amount, required Currency currency, String? notes});

  Future<Result<void>> cancelPayment(String id);

  Future<Result<PaginatedResult<AgentReturn>>> returns({int page = 1});

  Future<Result<AgentReturnDetail>> returnDetail(String id);

  Future<Result<AgentReturnDetail>> sendReturn(List<AgentReturnLineParams> lines, {String? notes});

  Future<Result<void>> cancelReturn(String id);

  Future<Result<PaginatedResult<AgentTransfer>>> transfers({int page = 1});

  Future<Result<AgentTransferDetail>> transfer(String id);

  Future<Result<PaginatedResult<AgentAccountUser>>> staff({String? search});

  Future<Result<AgentAccountUser>> createStaff(CreateAgentAccountParams params);

  Future<Result<AgentAccountUser>> updateStaff(String id, UpdateAgentAccountParams params);

  Future<Result<void>> setStaffActive(String id, bool isActive);

  Future<Result<void>> deleteStaff(String id);
}
