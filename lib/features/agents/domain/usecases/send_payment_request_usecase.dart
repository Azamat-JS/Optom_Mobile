import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/repositories/lead_agent_repository.dart';

class SendPaymentRequestUseCase {
  SendPaymentRequestUseCase(this._repository);

  final LeadAgentRepository _repository;

  Future<Result<AgentPaymentRequest>> call({required double amount, required Currency currency, String? notes}) =>
      _repository.sendPayment(amount: amount, currency: currency, notes: notes);
}
