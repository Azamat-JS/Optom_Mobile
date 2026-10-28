import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale_params.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';

/// What lead and staff agents work with — `Optom_Savdo/apps/server/src/agent/agent-panel.controller.ts`.
/// Scoping is server-side: a staff agent only ever gets what it made itself.
abstract class AgentsRepository {
  Future<Result<PaginatedResult<AgentStockItem>>> stock({String? search, int page = 1, int limit = 60});

  Future<Result<AgentSaleDetail>> createSale(CreateAgentSaleParams params);

  Future<Result<PaginatedResult<AgentSale>>> sales({String? search, int page = 1});

  Future<Result<AgentSaleDetail>> sale(String id);

  Future<Result<AgentDebtsPage>> debts({bool openOnly = true, String? search, int page = 1});

  Future<Result<AgentDebtDetail>> debt(String id);

  Future<Result<AgentDebtDetail>> payDebt(String id, {required double amount, String? notes});

  Future<Result<AgentSummary>> summary();

  Future<Result<AgentProfit>> profit(AgentProfitPeriod period);
}
