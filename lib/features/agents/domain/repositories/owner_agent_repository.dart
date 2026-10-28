import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';

/// The business owner's side of agents (Phase 10 A7c): its lead agents, handing them goods,
/// deciding on their payments and returns, and reading its teams' sales and customer debts.
/// Owner-only server-side (its admins get 403).
abstract class OwnerAgentRepository {
  Future<Result<PaginatedResult<AgentAccountUser>>> leads({String? search});

  Future<Result<AgentAccountUser>> createLead(CreateAgentAccountParams params);

  Future<Result<AgentAccountUser>> updateLead(String id, UpdateAgentAccountParams params);

  Future<Result<void>> setLeadActive(String id, bool isActive);

  Future<Result<void>> deleteLead(String id);

  Future<Result<LeadAgentSummary>> leadSummary(String id);

  Future<Result<AgentSummary>> teamSummary(String leadId);

  Future<Result<PaginatedResult<TransferableProduct>>> transferableProducts(String leadId, {String? search});

  Future<Result<PaginatedResult<AgentStockItem>>> leadStock(String leadId, {int page = 1});

  Future<Result<void>> updatePriceRange(
    String leadId,
    String agentProductId, {
    required double min,
    required double max,
  });

  Future<Result<AgentTransferDetail>> createTransfer(CreateAgentTransferParams params);

  Future<Result<PaginatedResult<AgentTransfer>>> transfers(String leadId, {int page = 1});

  Future<Result<PaginatedResult<AgentPaymentRequest>>> payments(String leadId, {int page = 1});

  Future<Result<void>> confirmPayment(String id);

  Future<Result<void>> rejectPayment(String id, {String? reason});

  Future<Result<PaginatedResult<AgentReturn>>> returns(String leadId, {int page = 1});

  Future<Result<void>> confirmReturn(String id);

  Future<Result<void>> rejectReturn(String id, {String? reason});

  Future<Result<PaginatedResult<AgentSale>>> teamSales(String leadId, {int page = 1});

  Future<Result<AgentSaleDetail>> teamSale(String leadId, String saleId);

  Future<Result<AgentDebtsPage>> teamDebts(String leadId, {bool openOnly = true, int page = 1});

  Future<Result<AgentDebtDetail>> teamDebt(String leadId, String debtId);
}
