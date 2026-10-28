import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/features/agents/data/models/lead_agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_money.dart';

// Shapes as Optom_Savdo's agent-request / agent-transfer / agent-account services send them.
void main() {
  const lead = {'id': 'l1', 'firstName': 'Ali', 'lastName': 'Diller', 'phone': '+998901112233'};

  test('account: shop name wins, available = debt − pending, never negative', () {
    final account = leadAgentAccountFromJson({
      'owner': {'id': 'o1', 'firstName': 'Olim', 'lastName': 'Ega', 'shopName': 'Baraka'},
      'debt': {'uzs': '10000.00', 'usd': '50.00'},
      'pendingPayments': {'uzs': '4000.00', 'usd': '80.00'},
      'pendingReturns': 2,
    });
    expect(account.ownerName, 'Baraka');
    expect(account.debt.uzs, 10000);
    expect(account.pendingReturns, 2);
    expect(account.available.uzs, 6000);
    expect(account.available.usd, 0);

    final noShop = leadAgentAccountFromJson({
      'owner': {'id': 'o1', 'firstName': 'Olim', 'lastName': 'Ega', 'shopName': null},
      'debt': {'uzs': 0, 'usd': 0},
      'pendingPayments': {'uzs': 0, 'usd': 0},
      'pendingReturns': 0,
    });
    expect(noShop.ownerName, 'Olim Ega');
  });

  test('payment request: status, currency, reject reason', () {
    final p = agentPaymentRequestFromJson({
      'id': 'pr1',
      'status': 'REJECTED',
      'amount': '25.50',
      'currency': 'USD',
      'notes': null,
      'rejectReason': 'Pul kelmadi',
      'createdAt': '2026-10-28T10:00:00.000Z',
      'decidedAt': '2026-10-28T11:00:00.000Z',
      'leadAgent': lead,
    });
    expect(p.status, AgentRequestStatus.rejected);
    expect(p.amount, 25.5);
    expect(p.currency, Currency.usd);
    expect(p.rejectReason, 'Pul kelmadi');
    expect(p.decidedAt, isNotNull);
  });

  test('return detail: lines carry their transfer number, refund parsed', () {
    final d = agentReturnDetailFromJson({
      'id': 'r1',
      'returnNumber': 'RT-20261028-AAA111',
      'status': 'CONFIRMED',
      'currency': 'UZS',
      'value': '8000.00',
      'refundAmount': '2000.00',
      'createdAt': '2026-10-28T10:00:00.000Z',
      'leadAgent': lead,
      'itemCount': 2,
      'items': [
        {
          'id': 'ri1',
          'productName': 'Choy',
          'productUnit': 'DONA',
          'quantity': '5.000',
          'unitPrice': '1200.00',
          'transferNumber': 'TR-20261028-BBB222',
        },
        {
          'id': 'ri2',
          'productName': 'Shakar',
          'productUnit': 'NOT_A_UNIT',
          'quantity': '2.000',
          'unitPrice': '1000.00',
          'transferNumber': 'TR-20261027-CCC333',
        },
      ],
    });
    expect(d.ret.status, AgentRequestStatus.confirmed);
    expect(d.ret.value, 8000);
    expect(d.ret.refundAmount, 2000);
    expect(d.ret.itemCount, 2);
    expect(d.lines.first.unit, ProductUnit.dona);
    expect(d.lines.first.transferNumber, 'TR-20261028-BBB222');
    expect(d.lines.last.unit, isNull);
  });

  test('transfer detail: debt fields; cost only when sent (owner view)', () {
    Map<String, dynamic> json({bool withCost = false}) => {
          'id': 't1',
          'transferNumber': 'TR-20261028-BBB222',
          'currency': 'UZS',
          'total': '10000.00',
          'paidAmount': '4000.00',
          'createdAt': '2026-10-28T10:00:00.000Z',
          'leadAgent': lead,
          'createdBy': {'id': 'o1', 'firstName': 'Olim', 'lastName': 'Ega'},
          'debt': {'id': 'd1', 'balance': '6000.00', 'status': 'PARTIAL'},
          'store': {'id': 's1', 'name': 'Bosh filial'},
          'itemCount': 1,
          'items': [
            {
              'id': 'ti1',
              'productName': 'Choy',
              'productUnit': 'DONA',
              'quantity': '10.000',
              'remaining': '3.000',
              'returnedQuantity': '2.000',
              'unitPrice': '1000.00',
              'total': '10000.00',
              'minPrice': '1100.00',
              'maxPrice': '1500.00',
              if (withCost) 'costPrice': '600.00',
            },
          ],
        };

    final lead_ = agentTransferDetailFromJson(json());
    expect(lead_.transfer.debtBalance, 6000);
    expect(lead_.transfer.debtStatus, DebtStatus.partial);
    expect(lead_.storeName, 'Bosh filial');
    expect(lead_.givenBy?.fullName, 'Olim Ega');
    expect(lead_.lines.single.remaining, 3);
    expect(lead_.lines.single.returnedQuantity, 2);
    expect(lead_.lines.single.costPrice, isNull);

    expect(agentTransferDetailFromJson(json(withCost: true)).lines.single.costPrice, 600);
  });

  test('staff account row', () {
    final u = agentAccountUserFromJson({
      'id': 'a1',
      'phone': '+998901234567',
      'firstName': 'Bobur',
      'lastName': 'Agent',
      'isActive': false,
      'createdAt': '2026-10-28T10:00:00.000Z',
    });
    expect(u.fullName, 'Bobur Agent');
    expect(u.isActive, isFalse);
    expect(u.storeId, isNull);
  });

  test('money text: so\'m shown when nothing owed, dollars only when present', () {
    expect(agentMoneyBoth(const MoneyByCurrency(uzs: 0, usd: 0)), isNot(contains(r'$')));
    expect(agentMoneyBoth(const MoneyByCurrency(uzs: 0, usd: 12)), contains(r'$'));
    expect(agentMoneyBoth(const MoneyByCurrency(uzs: 5000, usd: 12)), contains(' · '));
  });
}
