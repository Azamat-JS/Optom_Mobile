import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/features/agents/data/models/owner_agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';

// Shapes as Optom_Savdo's /lead-agents/:id and /lead-agents/:id/transferable-products send them.
void main() {
  test('lead agent summary: store, money per currency, pending counts', () {
    final s = leadAgentSummaryFromJson({
      'id': 'l1',
      'firstName': 'Ali',
      'lastName': 'Diller',
      'phone': '+998901112233',
      'isActive': true,
      'agentStoreId': 's1',
      'agentStore': {'id': 's1', 'name': 'Bosh filial'},
      'createdAt': '2026-10-28T10:00:00.000Z',
      'staffCount': 2,
      'stockValue': {'uzs': '350000.00', 'usd': 0},
      'debt': {'uzs': '320000.00', 'usd': '15.50'},
      'pendingPayments': 1,
      'pendingReturns': 3,
    });
    expect(s.fullName, 'Ali Diller');
    expect(s.storeName, 'Bosh filial');
    expect(s.staffCount, 2);
    expect(s.stockValue.uzs, 350000);
    expect(s.debt.usd, 15.5);
    expect(s.pendingPayments, 1);
    expect(s.pendingReturns, 3);
  });

  test('transferable product: with and without the lead agent\'s current range', () {
    Map<String, dynamic> json({Map<String, dynamic>? agent}) => {
      'id': 'p1',
      'name': 'Choy',
      'unit': 'DONA',
      'barcode': null,
      'imageUrl': null,
      'price': '10000.00',
      'currency': 'UZS',
      'stock': '50.000',
      'agent': agent,
    };

    final fresh = transferableProductFromJson(json());
    expect(fresh.product.unit, ProductUnit.dona);
    expect(fresh.price, 10000);
    expect(fresh.currency, Currency.uzs);
    expect(fresh.stock, 50);
    expect(fresh.agentMinPrice, isNull);

    final held = transferableProductFromJson(json(agent: {'stock': '8.000', 'minPrice': '11000.00', 'maxPrice': '14000.00'}));
    expect(held.agentStock, 8);
    expect(held.agentMinPrice, 11000);
    expect(held.agentMaxPrice, 14000);
  });

  test('transfer request body: no paidAmount when nothing paid, notes only when set', () {
    const line = AgentTransferLineParams(productId: 'p1', quantity: 5, minPrice: 11000, maxPrice: 14000);
    final unpaid = const CreateAgentTransferParams(leadAgentId: 'l1', lines: [line]).toRequestBody();
    expect(unpaid.containsKey('paidAmount'), isFalse);
    expect(unpaid.containsKey('notes'), isFalse);
    expect(unpaid['items'], [
      {'productId': 'p1', 'quantity': 5.0, 'minPrice': 11000.0, 'maxPrice': 14000.0},
    ]);

    final paid = const CreateAgentTransferParams(
      leadAgentId: 'l1',
      lines: [line],
      paidAmount: 20000,
      notes: 'Naqd',
    ).toRequestBody();
    expect(paid['paidAmount'], 20000);
    expect(paid['notes'], 'Naqd');
  });
}
