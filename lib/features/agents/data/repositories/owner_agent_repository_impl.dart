import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/data/datasources/owner_agent_remote_data_source.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class OwnerAgentRepositoryImpl implements OwnerAgentRepository {
  OwnerAgentRepositoryImpl(this._remote);

  final OwnerAgentRemoteDataSource _remote;

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.ok(await call());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PaginatedResult<AgentAccountUser>>> leads({String? search}) =>
      _guard(() => _remote.leads(search: search));

  @override
  Future<Result<AgentAccountUser>> createLead(CreateAgentAccountParams params) =>
      _guard(() => _remote.createLead(params));

  @override
  Future<Result<AgentAccountUser>> updateLead(String id, UpdateAgentAccountParams params) =>
      _guard(() => _remote.updateLead(id, params));

  @override
  Future<Result<void>> setLeadActive(String id, bool isActive) => _guard(() => _remote.setLeadActive(id, isActive));

  @override
  Future<Result<void>> deleteLead(String id) => _guard(() => _remote.deleteLead(id));

  @override
  Future<Result<LeadAgentSummary>> leadSummary(String id) => _guard(() => _remote.leadSummary(id));

  @override
  Future<Result<AgentSummary>> teamSummary(String leadId) => _guard(() => _remote.teamSummary(leadId));

  @override
  Future<Result<PaginatedResult<TransferableProduct>>> transferableProducts(String leadId, {String? search}) =>
      _guard(() => _remote.transferableProducts(leadId, search: search));

  @override
  Future<Result<PaginatedResult<AgentStockItem>>> leadStock(String leadId, {int page = 1}) =>
      _guard(() => _remote.leadStock(leadId, page: page));

  @override
  Future<Result<void>> updatePriceRange(
    String leadId,
    String agentProductId, {
    required double min,
    required double max,
  }) => _guard(() => _remote.updatePriceRange(leadId, agentProductId, min: min, max: max));

  @override
  Future<Result<AgentTransferDetail>> createTransfer(CreateAgentTransferParams params) =>
      _guard(() => _remote.createTransfer(params));

  @override
  Future<Result<PaginatedResult<AgentTransfer>>> transfers(String leadId, {int page = 1}) =>
      _guard(() => _remote.transfers(leadId, page: page));

  @override
  Future<Result<PaginatedResult<AgentPaymentRequest>>> payments(String leadId, {int page = 1}) =>
      _guard(() => _remote.payments(leadId, page: page));

  @override
  Future<Result<void>> confirmPayment(String id) => _guard(() => _remote.confirmPayment(id));

  @override
  Future<Result<void>> rejectPayment(String id, {String? reason}) =>
      _guard(() => _remote.rejectPayment(id, reason: reason));

  @override
  Future<Result<PaginatedResult<AgentReturn>>> returns(String leadId, {int page = 1}) =>
      _guard(() => _remote.returns(leadId, page: page));

  @override
  Future<Result<void>> confirmReturn(String id) => _guard(() => _remote.confirmReturn(id));

  @override
  Future<Result<void>> rejectReturn(String id, {String? reason}) =>
      _guard(() => _remote.rejectReturn(id, reason: reason));

  @override
  Future<Result<PaginatedResult<AgentSale>>> teamSales(String leadId, {int page = 1}) =>
      _guard(() => _remote.teamSales(leadId, page: page));

  @override
  Future<Result<AgentSaleDetail>> teamSale(String leadId, String saleId) =>
      _guard(() => _remote.teamSale(leadId, saleId));

  @override
  Future<Result<AgentDebtsPage>> teamDebts(String leadId, {bool openOnly = true, int page = 1}) =>
      _guard(() => _remote.teamDebts(leadId, openOnly: openOnly, page: page));

  @override
  Future<Result<AgentDebtDetail>> teamDebt(String leadId, String debtId) =>
      _guard(() => _remote.teamDebt(leadId, debtId));
}
