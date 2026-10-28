import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/data/datasources/agents_remote_data_source.dart';
import 'package:bsmart/features/agents/domain/entities/agent_dashboard.dart';
import 'package:bsmart/features/agents/domain/entities/agent_debt.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale_params.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/domain/repositories/agents_repository.dart';

class AgentsRepositoryImpl implements AgentsRepository {
  AgentsRepositoryImpl(this._remote);

  final AgentsRemoteDataSource _remote;

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.ok(await call());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PaginatedResult<AgentStockItem>>> stock({String? search, int page = 1, int limit = 60}) =>
      _guard(() => _remote.stock(search: search, page: page, limit: limit));

  @override
  Future<Result<AgentSaleDetail>> createSale(CreateAgentSaleParams params) => _guard(() => _remote.createSale(params));

  @override
  Future<Result<PaginatedResult<AgentSale>>> sales({String? search, int page = 1}) =>
      _guard(() => _remote.sales(search: search, page: page));

  @override
  Future<Result<AgentSaleDetail>> sale(String id) => _guard(() => _remote.sale(id));

  @override
  Future<Result<AgentDebtsPage>> debts({bool openOnly = true, String? search, int page = 1}) =>
      _guard(() => _remote.debts(openOnly: openOnly, search: search, page: page));

  @override
  Future<Result<AgentDebtDetail>> debt(String id) => _guard(() => _remote.debt(id));

  @override
  Future<Result<AgentDebtDetail>> payDebt(String id, {required double amount, String? notes}) =>
      _guard(() => _remote.payDebt(id, amount: amount, notes: notes));

  @override
  Future<Result<AgentSummary>> summary() => _guard(_remote.summary);

  @override
  Future<Result<AgentProfit>> profit(AgentProfitPeriod period) => _guard(() => _remote.profit(period));
}
