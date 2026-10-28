import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/features/agents/data/models/agent_models.dart';
import 'package:bsmart/features/agents/domain/entities/agent_sale.dart';

// Shapes as Optom_Savdo's agent endpoints send them (decimals as strings) — "Agents (Dillers)".
void main() {
  test('stock row: decimals parsed, range check is inclusive', () {
    final item = agentStockItemFromJson({
      'id': 'ap1',
      'currency': 'UZS',
      'stock': '12.000',
      'minPrice': '1100.00',
      'maxPrice': '1500.00',
      'updatedAt': '2026-10-28T10:00:00.000Z',
      'product': {'id': 'p1', 'name': 'Choy', 'unit': 'DONA', 'barcode': null, 'imageUrl': null},
    });
    expect(item.stock, 12);
    expect(item.currency, Currency.uzs);
    expect(item.product.unit, ProductUnit.dona);
    expect(item.allows(1100), isTrue);
    expect(item.allows(1500), isTrue);
    expect(item.allows(1099.99), isFalse);
    expect(item.allows(1500.01), isFalse);
  });

  test('sale list item: debt fields, seller and walk-in buyer', () {
    final sale = agentSaleFromJson({
      'id': 's1',
      'saleNumber': 'SALE-20261028-ABC123',
      'type': 'DEBT',
      'currency': 'USD',
      'total': '24.50',
      'createdAt': '2026-10-28T10:00:00.000Z',
      'customer': {'id': 'c1', 'firstName': 'Mehmon', 'lastName': 'xaridor', 'phone': agentWalkInPhone},
      'createdBy': {'id': 'u2', 'firstName': 'Bobur', 'lastName': 'Agent'},
      'debt': {'id': 'd1', 'balance': '10.00', 'status': 'PARTIAL'},
      'itemCount': 2,
    });
    expect(sale.type, SaleType.debt);
    expect(sale.total, 24.5);
    expect(sale.debtBalance, 10);
    expect(sale.debtStatus, DebtStatus.partial);
    expect(sale.seller?.fullName, 'Bobur Agent');
    expect(sale.customer.phone, agentWalkInPhone);
  });

  test('sale detail: cost only when sent (lead agent), unknown unit snapshot is null', () {
    final detail = agentSaleDetailFromJson({
      'id': 's1',
      'saleNumber': 'SALE-1',
      'type': 'PAID',
      'currency': 'UZS',
      'total': '9100',
      'createdAt': '2026-10-28T10:00:00.000Z',
      'customer': {'id': 'c1', 'firstName': 'Ali', 'lastName': '', 'phone': '+998901112233'},
      'createdBy': null,
      'debt': null,
      'notes': null,
      'items': [
        {'id': 'i1', 'productId': 'p1', 'productName': 'Choy', 'productUnit': 'DONA', 'quantity': '7', 'unitPrice': '1300', 'total': '9100', 'costPrice': '1057.14'},
        {'id': 'i2', 'productId': null, 'productName': 'Eski', 'productUnit': 'QUTI', 'quantity': '1', 'unitPrice': '0', 'total': '0'},
      ],
    });
    expect(detail.sale.itemCount, 2);
    expect(detail.lines.first.costPrice, closeTo(1057.14, 0.001));
    expect(detail.lines.last.costPrice, isNull);
    expect(detail.lines.last.unit, isNull);
    expect(detail.sale.debtBalance, isNull);
  });

  test('summary: lead-only fields are null for a staff agent', () {
    final staff = agentSummaryFromJson({
      'today': {'count': 1, 'revenue': {'uzs': 4200, 'usd': 0}},
      'last30': {'count': 3, 'revenue': {'uzs': 9000, 'usd': 12.5}},
      'customerDebt': {'uzs': 0, 'usd': 0},
      'openDebtCount': 0,
    });
    expect(staff.todayRevenue.uzs, 4200);
    expect(staff.monthRevenue.usd, 12.5);
    expect(staff.debtToOwner, isNull);
    expect(staff.stockValue, isNull);

    final lead = agentSummaryFromJson({
      'today': {'count': 2, 'revenue': {'uzs': 6800, 'usd': 0}},
      'last30': {'count': 2, 'revenue': {'uzs': 6800, 'usd': 0}},
      'customerDebt': {'uzs': 1300, 'usd': 0},
      'openDebtCount': 1,
      'debtToOwner': {'uzs': 4000, 'usd': 0},
      'stockValue': {'uzs': 3000, 'usd': 0},
    });
    expect(lead.debtToOwner?.uzs, 4000);
    expect(lead.stockValue?.uzs, 3000);
  });

  test('profit: summary per currency (same shape as /reports/profit)', () {
    final profit = agentProfitFromJson({
      'from': '2026-10-28T00:00:00.000Z',
      'to': '2026-10-29T00:00:00.000Z',
      'summary': {
        'uzs': {'salesCount': 2, 'revenue': 6800, 'cost': 5000, 'netProfit': 1500, 'pendingProfit': 300, 'ownDebts': 4000, 'expenses': null},
        'usd': {'salesCount': 0, 'revenue': 0, 'cost': 0, 'netProfit': 0, 'pendingProfit': 0, 'ownDebts': 0, 'expenses': null},
      },
      'daily': {'uzs': [], 'usd': []},
    });
    expect(profit.uzs.netProfit, 1500);
    expect(profit.uzs.pendingProfit, 300);
    expect(profit.uzs.ownDebts, 4000);
    expect(profit.usd.revenue, 0);
  });

  test('debt detail: payments in order with who took them', () {
    final detail = agentDebtDetailFromJson({
      'id': 'd1',
      'originalAmount': '4900.00',
      'paidAmount': '900.00',
      'balance': '4000.00',
      'currency': 'UZS',
      'status': 'PARTIAL',
      'createdAt': '2026-10-28T10:00:00.000Z',
      'customer': {'id': 'c1', 'firstName': 'Ali', 'lastName': '', 'phone': '+998901112233'},
      'createdBy': {'id': 'u2', 'firstName': 'Bobur', 'lastName': 'Agent'},
      'sale': {'id': 's1', 'saleNumber': 'SALE-1'},
      'payments': [
        {'id': 'p1', 'amount': '900.00', 'method': 'CASH', 'notes': null, 'paidAt': '2026-10-28T11:00:00.000Z', 'createdBy': {'id': 'u2', 'firstName': 'Bobur', 'lastName': 'Agent'}},
      ],
    });
    expect(detail.debt.isOpen, isTrue);
    expect(detail.debt.balance, 4000);
    expect(detail.debt.saleNumber, 'SALE-1');
    expect(detail.payments.single.amount, 900);
    expect(detail.payments.single.by?.firstName, 'Bobur');
  });
}
