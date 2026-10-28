import 'package:dio/dio.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/agents/data/models/agent_models.dart';
import 'package:bsmart/features/agents/data/models/lead_agent_models.dart';
import 'package:bsmart/features/agents/data/models/owner_agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';

/// The owner's agent endpoints: `/lead-agents/*`, and `/agent-transfers`, `/agent-payments`,
/// `/agent-returns` filtered to one lead agent.
class OwnerAgentRemoteDataSource {
  OwnerAgentRemoteDataSource(this._dio);

  final Dio _dio;

  static const _pageSize = 20;

  Future<PaginatedResult<AgentAccountUser>> leads({String? search}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/lead-agents',
      queryParameters: {'limit': 100, if (search != null && search.isNotEmpty) 'search': search},
    );
    return PaginatedResult.fromJson(response.data!, agentAccountUserFromJson);
  }

  Future<AgentAccountUser> createLead(CreateAgentAccountParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/lead-agents', data: params.toRequestBody());
    return agentAccountUserFromJson(response.data!);
  }

  Future<AgentAccountUser> updateLead(String id, UpdateAgentAccountParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/lead-agents/$id', data: params.toRequestBody());
    return agentAccountUserFromJson(response.data!);
  }

  Future<void> setLeadActive(String id, bool isActive) =>
      _dio.patch<void>('/lead-agents/$id/${isActive ? 'activate' : 'deactivate'}');

  Future<void> deleteLead(String id) => _dio.delete<void>('/lead-agents/$id');

  Future<LeadAgentSummary> leadSummary(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/lead-agents/$id');
    return leadAgentSummaryFromJson(response.data!);
  }

  Future<AgentSummary> teamSummary(String leadId) async {
    final response = await _dio.get<Map<String, dynamic>>('/lead-agents/$leadId/team-summary');
    return agentSummaryFromJson(response.data!);
  }

  Future<PaginatedResult<TransferableProduct>> transferableProducts(String leadId, {String? search}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/lead-agents/$leadId/transferable-products',
      queryParameters: {'limit': 60, if (search != null && search.isNotEmpty) 'search': search},
    );
    return PaginatedResult.fromJson(response.data!, transferableProductFromJson);
  }

  Future<PaginatedResult<AgentStockItem>> leadStock(String leadId, {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/lead-agents/$leadId/stock',
      queryParameters: {'page': page, 'limit': _pageSize},
    );
    return PaginatedResult.fromJson(response.data!, agentStockItemFromJson);
  }

  Future<void> updatePriceRange(String leadId, String agentProductId, {required double min, required double max}) =>
      _dio.patch<void>('/lead-agents/$leadId/stock/$agentProductId', data: {'minPrice': min, 'maxPrice': max});

  Future<AgentTransferDetail> createTransfer(CreateAgentTransferParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/agent-transfers', data: params.toRequestBody());
    return agentTransferDetailFromJson(response.data!);
  }

  Future<PaginatedResult<AgentTransfer>> transfers(String leadId, {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent-transfers',
      queryParameters: {'leadAgentId': leadId, 'page': page, 'limit': _pageSize},
    );
    return PaginatedResult.fromJson(response.data!, agentTransferFromJson);
  }

  Future<PaginatedResult<AgentPaymentRequest>> payments(String leadId, {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent-payments',
      queryParameters: {'leadAgentId': leadId, 'page': page, 'limit': _pageSize},
    );
    return PaginatedResult.fromJson(response.data!, agentPaymentRequestFromJson);
  }

  Future<void> confirmPayment(String id) => _dio.patch<void>('/agent-payments/$id/confirm');

  Future<void> rejectPayment(String id, {String? reason}) =>
      _dio.patch<void>('/agent-payments/$id/reject', data: {if (reason != null && reason.isNotEmpty) 'reason': reason});

  Future<PaginatedResult<AgentReturn>> returns(String leadId, {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent-returns',
      queryParameters: {'leadAgentId': leadId, 'page': page, 'limit': _pageSize},
    );
    return PaginatedResult.fromJson(response.data!, agentReturnFromJson);
  }

  Future<void> confirmReturn(String id) => _dio.patch<void>('/agent-returns/$id/confirm');

  Future<void> rejectReturn(String id, {String? reason}) =>
      _dio.patch<void>('/agent-returns/$id/reject', data: {if (reason != null && reason.isNotEmpty) 'reason': reason});

  Future<PaginatedResult<AgentSale>> teamSales(String leadId, {int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/lead-agents/$leadId/sales',
      queryParameters: {'page': page, 'limit': _pageSize},
    );
    return PaginatedResult.fromJson(response.data!, agentSaleFromJson);
  }

  Future<AgentSaleDetail> teamSale(String leadId, String saleId) async {
    final response = await _dio.get<Map<String, dynamic>>('/lead-agents/$leadId/sales/$saleId');
    return agentSaleDetailFromJson(response.data!);
  }

  Future<AgentDebtsPage> teamDebts(String leadId, {bool openOnly = true, int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/lead-agents/$leadId/customer-debts',
      queryParameters: {'page': page, 'limit': _pageSize, 'status': openOnly ? 'open' : 'all'},
    );
    final json = response.data!;
    final meta = json['meta'] as Map<String, dynamic>;
    final total = meta['totalBalance'] as Map<String, dynamic>? ?? const {};
    return AgentDebtsPage(
      items: [for (final e in json['data'] as List) agentDebtFromJson(e as Map<String, dynamic>)],
      hasNext: meta['hasNext'] as bool? ?? false,
      totalBalance: MoneyByCurrency(uzs: parseDecimal(total['uzs'] ?? 0), usd: parseDecimal(total['usd'] ?? 0)),
    );
  }

  Future<AgentDebtDetail> teamDebt(String leadId, String debtId) async {
    final response = await _dio.get<Map<String, dynamic>>('/lead-agents/$leadId/customer-debts/$debtId');
    return agentDebtDetailFromJson(response.data!);
  }
}
