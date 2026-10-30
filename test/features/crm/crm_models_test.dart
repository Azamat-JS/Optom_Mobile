import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/features/crm/data/models/crm_models.dart';
import 'package:bsmart/features/crm/domain/entities/crm_params.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';

// Shapes as Optom_Savdo's /crm endpoints send them (crm-driver.service.ts, crm-visit.service.ts).
void main() {
  test('driver with a car, its next reminder and the linked customer', () {
    final d = crmDriverFromJson({
      'id': 'd1',
      'firstName': 'Jasur',
      'lastName': '',
      'phone': '+998901112233',
      'notes': null,
      'imageUrl': 'https://ik.imagekit.io/x.png',
      'isActive': true,
      'createdAt': '2026-10-30T10:00:00.000Z',
      'customer': {'id': 'c1', 'firstName': 'Jasur', 'lastName': '', 'phone': '+998901112233', 'isActive': true},
      'vehicles': [
        {
          'id': 'v1',
          'plateNumber': '01A123BC',
          'model': 'Cobalt',
          'dailyKm': 120,
          'notes': null,
          'driverId': 'd1',
          'visitItems': [
            {'id': 'i1', 'productName': 'Moy', 'dueDate': '2026-12-11T00:00:00.000Z', 'dueOdometerKm': 105000},
          ],
        },
        {'id': 'v2', 'plateNumber': '01B222CC', 'model': 'Nexia', 'dailyKm': null, 'notes': null, 'driverId': 'd1', 'visitItems': []},
      ],
    });
    expect(d.fullName, 'Jasur');
    expect(d.customer!.fullName, 'Jasur');
    expect(d.vehicles.first.nextDue!.dueDate, DateTime.utc(2026, 12, 11));
    expect(d.vehicles.first.nextDue!.dueOdometerKm, 105000);
    expect(d.vehicles.last.dailyKm, isNull);
    expect(d.vehicles.last.nextDue, isNull);
  });

  test('visit: decimal strings, statuses, debt sale', () {
    final v = crmVisitFromJson({
      'id': 'vs1',
      'serviceDate': '2026-10-30T00:00:00.000Z',
      'odometerKm': 100000,
      'notes': null,
      'vehicle': {'id': 'v1', 'plateNumber': '01A123BC', 'model': 'Cobalt'},
      'items': [
        {
          'id': 'i1', 'productId': 'p1', 'productName': 'Moy', 'quantity': '4.000', 'unitPrice': '50000.00',
          'intervalKm': 5000, 'dueOdometerKm': 105000, 'dueDate': '2026-12-11T00:00:00.000Z', 'dueDateManual': false,
          'status': 'ACTIVE', 'closedAt': null, 'closedByVisitId': null,
        },
        {
          'id': 'i2', 'productId': null, 'productName': 'Ish haqi', 'quantity': '1.000', 'unitPrice': null,
          'intervalKm': null, 'dueOdometerKm': null, 'dueDate': null, 'dueDateManual': false,
          'status': 'DONE', 'closedAt': '2026-11-01T00:00:00.000Z', 'closedByVisitId': 'vs2',
        },
      ],
      'sale': {
        'id': 's1', 'saleNumber': 'S-1', 'type': 'DEBT', 'status': 'COMPLETED', 'total': '220000.00', 'currency': 'UZS',
        'debt': {'id': 'sd1', 'balance': '190000.00', 'status': 'PARTIAL'},
      },
    });
    expect(v.items.first.quantity, 4);
    expect(v.items.first.unitPrice, 50000);
    expect(v.items.last.status, CrmItemStatus.done);
    expect(v.items.last.closedByVisitId, 'vs2');
    expect(v.sale!.isDebt, isTrue);
    expect(v.sale!.currency, Currency.uzs);
    expect(v.sale!.debtBalance, 190000);
  });

  test('reminders page with tab counts', () {
    final page = crmReminderPageFromJson({
      'data': [
        {
          'id': 'i1', 'productId': null, 'productName': 'Antifriz', 'quantity': '1', 'unitPrice': null,
          'intervalKm': 1200, 'dueOdometerKm': null, 'dueDate': '2026-10-20T00:00:00.000Z', 'dueDateManual': true,
          'status': 'ACTIVE', 'closedAt': null, 'closedByVisitId': null,
          'visit': {'id': 'vs1', 'serviceDate': '2026-09-30T00:00:00.000Z', 'odometerKm': null},
          'vehicle': {
            'id': 'v1', 'plateNumber': '01A123BC', 'model': 'Cobalt', 'dailyKm': 100,
            'driver': {'id': 'd1', 'firstName': 'Jasur', 'lastName': 'Karimov', 'phone': '+998901112233', 'imageUrl': null},
          },
        },
      ],
      'meta': {'total': 1, 'page': 1, 'limit': 20, 'totalPages': 1, 'hasNext': false, 'hasPrev': false, 'counts': {'overdue': 1, 'soon': 0}},
    });
    expect(page.overdueCount, 1);
    expect(page.page.data.single.driver.fullName, 'Jasur Karimov');
    expect(page.page.data.single.item.dueDateManual, isTrue);
  });

  test('request bodies match the DTOs', () {
    final visit = CreateCrmVisitParams(
      vehicleId: 'v1',
      serviceDate: DateTime(2026, 10, 30, 22),
      recordSale: true,
      saleType: SaleType.debt,
      paidAmount: 10000,
      items: [
        const CrmVisitItemParams(productId: 'p1', quantity: 4, unitPrice: 50000, intervalKm: 5000),
        CrmVisitItemParams(productName: ' Ish haqi ', quantity: 1, unitPrice: 20000, dueDate: DateTime(2026, 12, 1)),
      ],
    ).toRequestBody();
    expect(visit['serviceDate'], '2026-10-30');
    expect(visit['paymentType'], 'DEBT');
    expect(visit['paidAmount'], 10000);
    final items = visit['items'] as List;
    expect(items.first, {'productId': 'p1', 'quantity': 4.0, 'unitPrice': 50000.0, 'intervalKm': 5000});
    expect(items.last, {'productName': 'Ish haqi', 'quantity': 1.0, 'unitPrice': 20000.0, 'dueDate': '2026-12-01'});

    final noSale = CreateCrmVisitParams(
      vehicleId: 'v1',
      serviceDate: DateTime(2026, 10, 30),
      recordSale: false,
      items: const [CrmVisitItemParams(productName: 'X', quantity: 1)],
    ).toRequestBody();
    expect(noSale.containsKey('paymentType'), isFalse);
    expect(noSale['recordSale'], isFalse);

    // Clearing daily km must send an explicit null.
    expect(const CrmVehicleParams(plateNumber: '01A123BC', model: 'Cobalt').toRequestBody()['dailyKm'], isNull);
    expect(const CrmVehicleParams(plateNumber: '01A123BC', model: 'Cobalt').toRequestBody().containsKey('dailyKm'), isTrue);
    expect(const CrmDriverQuery(activeOnly: false).toQueryParameters()['status'], 'inactive');
  });
}
