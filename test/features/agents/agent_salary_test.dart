import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/features/agents/data/models/agent_models.dart';
import 'package:bsmart/features/agents/data/models/lead_agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';

// The lead agent's salary (Optom_Savdo "Agents (Dillers)" → "Diller salary"): per-transfer %,
// earned on what the team sold from that transfer. Shapes as the server sends them.
void main() {
  const lead = {'id': 'l1', 'firstName': 'Lola', 'lastName': 'Diller', 'phone': '+998901112233'};

  Map<String, dynamic> transfer({Map<String, dynamic>? salary, Object? percent}) => {
    'id': 't1',
    'transferNumber': 'TR-20261104-AAA111',
    'currency': 'UZS',
    'total': '10000.00',
    'paidAmount': '0.00',
    'createdAt': '2026-11-04T10:00:00.000Z',
    'leadAgent': lead,
    'itemCount': 1,
    'salaryPercent': ?percent,
    'salary': ?salary,
  };

  test('transfer: salary % and what it earned, decimals as strings', () {
    final t = agentTransferFromJson(
      transfer(percent: '7.50', salary: {'soldQuantity': 5, 'soldRevenue': 6500, 'salary': 487.5}),
    );
    expect(t.salaryPercent, 7.5);
    expect(t.salarySoldQuantity, 5);
    expect(t.salarySoldRevenue, 6500);
    expect(t.salaryEarned, 487.5);
  });

  test('transfer from an older server (no salary fields) reads as 0 %', () {
    final t = agentTransferFromJson(transfer());
    expect(t.salaryPercent, 0);
    expect(t.salaryEarned, 0);
  });

  test('summary: salary for the lead agent / owner team view, none for a staff agent', () {
    Map<String, dynamic> base() => {
      'today': {'count': 1, 'revenue': {'uzs': 1300, 'usd': 0}},
      'last30': {'count': 1, 'revenue': {'uzs': 1300, 'usd': 0}},
      'customerDebt': {'uzs': 0, 'usd': 0},
      'openDebtCount': 0,
    };
    expect(agentSummaryFromJson(base()).salary, isNull);

    final withSalary = agentSummaryFromJson({
      ...base(),
      'salary': {
        'today': {'uzs': 65, 'usd': 0},
        'last30': {'uzs': 1041, 'usd': 2.4},
        'total': {'uzs': 1641, 'usd': 2.4},
      },
    });
    expect(withSalary.salary!.today.uzs, 65);
    expect(withSalary.salary!.last30.usd, 2.4);
    expect(withSalary.salary!.total.uzs, 1641);
  });

  test('profit: salaryIncome parsed, 0 when absent', () {
    Map<String, dynamic> stats(Map<String, dynamic> extra) => {
      'salesCount': 1, 'revenue': 14400, 'cost': 12000, 'netProfit': 3441, 'pendingProfit': 900, 'ownDebts': 0,
      ...extra,
    };
    final profit = agentProfitFromJson({
      'summary': {'uzs': stats({'salaryIncome': 1041}), 'usd': stats({})},
    });
    expect(profit.uzs.salaryIncome, 1041);
    expect(profit.usd.salaryIncome, 0);
  });

  test('transfer request body: salaryPercent only when above 0', () {
    const line = AgentTransferLineParams(productId: 'p1', quantity: 5, price: 1300, discountPercent: 10);
    expect(
      const CreateAgentTransferParams(leadAgentId: 'l1', lines: [line]).toRequestBody().containsKey('salaryPercent'),
      isFalse,
    );
    expect(
      const CreateAgentTransferParams(leadAgentId: 'l1', lines: [line], salaryPercent: 5.25).toRequestBody()['salaryPercent'],
      5.25,
    );
  });
}
