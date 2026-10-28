import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/features/agents/domain/entities/agent_sale_params.dart';

// `POST /agent/sales`: a debt can carry `paidAmount` (paid now, the rest is owed); cash never does.
void main() {
  const line = AgentSaleLineParams(agentProductId: 'ap1', quantity: 2, unitPrice: 12000);
  const buyer = AgentSaleCustomerParams(firstName: 'Bobur', phone: '+998901239999');

  test('debt with an up-front payment sends paidAmount', () {
    final body = const CreateAgentSaleParams(
      lines: [line],
      paymentType: AgentPaymentType.debt,
      customer: buyer,
      paidAmount: 10000,
    ).toRequestBody();
    expect(body['paymentType'], 'DEBT');
    expect(body['paidAmount'], 10000);
  });

  test('debt with nothing paid, and cash, send no paidAmount', () {
    final unpaid = const CreateAgentSaleParams(
      lines: [line],
      paymentType: AgentPaymentType.debt,
      customer: buyer,
      paidAmount: 0,
    ).toRequestBody();
    expect(unpaid.containsKey('paidAmount'), isFalse);

    final cash = const CreateAgentSaleParams(
      lines: [line],
      paymentType: AgentPaymentType.cash,
      paidAmount: 5000,
    ).toRequestBody();
    expect(cash.containsKey('paidAmount'), isFalse);
  });
}
