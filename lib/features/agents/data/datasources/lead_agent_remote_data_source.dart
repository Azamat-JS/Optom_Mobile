import 'package:dio/dio.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/agents/data/models/lead_agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';

/// Lists here use one generous page: a lead agent's requests, transfers and staff are small
/// working sets; the screens add "load more" only where they can grow (transfers).
class LeadAgentRemoteDataSource {
  LeadAgentRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LeadAgentAccount> account() async {
    final response = await _dio.get<Map<String, dynamic>>('/agent/account');
    return leadAgentAccountFromJson(response.data!);
  }

  Future<PaginatedResult<AgentPaymentRequest>> paymentRequests({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent-payments',
      queryParameters: {'page': page, 'limit': 50},
    );
    return PaginatedResult.fromJson(response.data!, agentPaymentRequestFromJson);
  }

  Future<AgentPaymentRequest> sendPayment({required double amount, required Currency currency, String? notes}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/agent-payments',
      data: {'amount': amount, 'currency': currency.toWire(), if (notes != null && notes.isNotEmpty) 'notes': notes},
    );
    return agentPaymentRequestFromJson(response.data!);
  }

  Future<void> cancelPayment(String id) => _dio.patch<void>('/agent-payments/$id/cancel');

  Future<PaginatedResult<AgentReturn>> returns({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent-returns',
      queryParameters: {'page': page, 'limit': 50},
    );
    return PaginatedResult.fromJson(response.data!, agentReturnFromJson);
  }

  Future<AgentReturnDetail> returnDetail(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/agent-returns/$id');
    return agentReturnDetailFromJson(response.data!);
  }

  Future<AgentReturnDetail> sendReturn(List<AgentReturnLineParams> lines, {String? notes}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/agent-returns',
      data: {
        'items': [for (final l in lines) l.toJson()],
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    return agentReturnDetailFromJson(response.data!);
  }

  Future<void> cancelReturn(String id) => _dio.patch<void>('/agent-returns/$id/cancel');

  Future<PaginatedResult<AgentTransfer>> transfers({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent-transfers',
      queryParameters: {'page': page, 'limit': 20},
    );
    return PaginatedResult.fromJson(response.data!, agentTransferFromJson);
  }

  Future<AgentTransferDetail> transfer(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/agent-transfers/$id');
    return agentTransferDetailFromJson(response.data!);
  }

  Future<PaginatedResult<AgentAccountUser>> staff({String? search}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/agent-staff',
      queryParameters: {'limit': 100, if (search != null && search.isNotEmpty) 'search': search},
    );
    return PaginatedResult.fromJson(response.data!, agentAccountUserFromJson);
  }

  Future<AgentAccountUser> createStaff(CreateAgentAccountParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/agent-staff', data: params.toRequestBody());
    return agentAccountUserFromJson(response.data!);
  }

  Future<AgentAccountUser> updateStaff(String id, UpdateAgentAccountParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/agent-staff/$id', data: params.toRequestBody());
    return agentAccountUserFromJson(response.data!);
  }

  Future<void> setStaffActive(String id, bool isActive) =>
      _dio.patch<void>('/agent-staff/$id/${isActive ? 'activate' : 'deactivate'}');

  Future<void> deleteStaff(String id) => _dio.delete<void>('/agent-staff/$id');
}
