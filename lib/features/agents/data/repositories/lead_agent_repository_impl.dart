import 'package:dio/dio.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/data/datasources/lead_agent_remote_data_source.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class LeadAgentRepositoryImpl implements LeadAgentRepository {
  LeadAgentRepositoryImpl(this._remote);

  final LeadAgentRemoteDataSource _remote;

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Result.ok(await call());
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<LeadAgentAccount>> account() => _guard(_remote.account);

  @override
  Future<Result<PaginatedResult<AgentPaymentRequest>>> paymentRequests({int page = 1}) =>
      _guard(() => _remote.paymentRequests(page: page));

  @override
  Future<Result<AgentPaymentRequest>> sendPayment({required double amount, required Currency currency, String? notes}) =>
      _guard(() => _remote.sendPayment(amount: amount, currency: currency, notes: notes));

  @override
  Future<Result<void>> cancelPayment(String id) => _guard(() => _remote.cancelPayment(id));

  @override
  Future<Result<PaginatedResult<AgentReturn>>> returns({int page = 1}) => _guard(() => _remote.returns(page: page));

  @override
  Future<Result<AgentReturnDetail>> returnDetail(String id) => _guard(() => _remote.returnDetail(id));

  @override
  Future<Result<AgentReturnDetail>> sendReturn(List<AgentReturnLineParams> lines, {String? notes}) =>
      _guard(() => _remote.sendReturn(lines, notes: notes));

  @override
  Future<Result<void>> cancelReturn(String id) => _guard(() => _remote.cancelReturn(id));

  @override
  Future<Result<PaginatedResult<AgentTransfer>>> transfers({int page = 1}) => _guard(() => _remote.transfers(page: page));

  @override
  Future<Result<AgentTransferDetail>> transfer(String id) => _guard(() => _remote.transfer(id));

  @override
  Future<Result<PaginatedResult<AgentAccountUser>>> staff({String? search}) => _guard(() => _remote.staff(search: search));

  @override
  Future<Result<AgentAccountUser>> createStaff(CreateAgentAccountParams params) => _guard(() => _remote.createStaff(params));

  @override
  Future<Result<AgentAccountUser>> updateStaff(String id, UpdateAgentAccountParams params) =>
      _guard(() => _remote.updateStaff(id, params));

  @override
  Future<Result<void>> setStaffActive(String id, bool isActive) => _guard(() => _remote.setStaffActive(id, isActive));

  @override
  Future<Result<void>> deleteStaff(String id) => _guard(() => _remote.deleteStaff(id));
}
