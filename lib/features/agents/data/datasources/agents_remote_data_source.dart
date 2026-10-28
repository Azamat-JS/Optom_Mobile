import 'package:dio/dio.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/agents/data/models/agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale_params.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';

class AgentsRemoteDataSource {
  AgentsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<AgentStockItem>> stock({String? search, int page = 1, int limit = 60}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent/stock',
      queryParameters: {'page': page, 'limit': limit, if (search != null && search.isNotEmpty) 'search': search},
    );
    return PaginatedResult.fromJson(response.data!, agentStockItemFromJson);
  }

  Future<AgentSaleDetail> createSale(CreateAgentSaleParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/agent/sales', data: params.toRequestBody());
    return agentSaleDetailFromJson(response.data!);
  }

  Future<PaginatedResult<AgentSale>> sales({String? search, int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent/sales',
      queryParameters: {'page': page, 'limit': 20, if (search != null && search.isNotEmpty) 'search': search},
    );
    return PaginatedResult.fromJson(response.data!, agentSaleFromJson);
  }

  Future<AgentSaleDetail> sale(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/agent/sales/$id');
    return agentSaleDetailFromJson(response.data!);
  }

  Future<AgentDebtsPage> debts({bool openOnly = true, String? search, int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent/debts',
      queryParameters: {
        'page': page,
        'limit': 20,
        'status': openOnly ? 'open' : 'all',
        if (search != null && search.isNotEmpty) 'search': search,
      },
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

  Future<AgentDebtDetail> debt(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/agent/debts/$id');
    return agentDebtDetailFromJson(response.data!);
  }

  Future<AgentDebtDetail> payDebt(String id, {required double amount, String? notes}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/agent/debts/$id/payments',
      data: {'amount': amount, if (notes != null && notes.isNotEmpty) 'notes': notes},
    );
    return agentDebtDetailFromJson(response.data!);
  }

  Future<AgentSummary> summary() async {
    final response = await _dio.get<Map<String, dynamic>>('/agent/summary');
    return agentSummaryFromJson(response.data!);
  }

  Future<AgentProfit> profit(AgentProfitPeriod period) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent/profit',
      queryParameters: {'period': period.toWire()},
    );
    return agentProfitFromJson(response.data!);
  }
}
