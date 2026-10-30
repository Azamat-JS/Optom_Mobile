import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/features/notifications/data/models/app_notification_model.dart';

// Shapes as Optom_Savdo's /notifications sends them (notification.service.ts, CrmServiceDueData).
void main() {
  test('page: staff service reminder, unread count', () {
    final page = notificationPageFromJson({
      'data': [
        {
          'id': 'n1',
          'type': 'CRM_SERVICE_DUE',
          'storeId': 's1',
          'readAt': null,
          'createdAt': '2026-10-31T04:00:00.000Z',
          'data': {
            'audience': 'staff', 'storeName': 'Avto Mir', 'driverId': 'd1', 'driverName': 'Jasur', 'driverPhone': '+998901112233',
            'vehicleId': 'v1', 'plate': '01 A 123 BC', 'model': 'Cobalt',
            'items': [{'name': 'Moy', 'dueDate': '2026-11-02'}],
            'driverNotified': false,
          },
        },
        {'id': 'n2', 'type': 'SOMETHING_NEW', 'storeId': null, 'readAt': '2026-10-31T05:00:00.000Z', 'createdAt': '2026-10-30T04:00:00.000Z', 'data': {}},
      ],
      'meta': {'total': 2, 'page': 1, 'limit': 20, 'totalPages': 1, 'hasNext': false, 'hasPrev': false, 'unread': 1},
    });
    expect(page.unread, 1);
    final due = page.items.first.serviceDue!;
    expect(due.forDriver, isFalse);
    expect(due.driverNotified, isFalse);
    expect(due.items.single.dueDate, DateTime.utc(2026, 11, 2));
    expect(page.items.first.isRead, isFalse);
    expect(page.items.last.serviceDue, isNull);
    expect(page.items.last.isRead, isTrue);
    expect(page.items.first.markedRead(DateTime.utc(2026)).isRead, isTrue);
  });
}
