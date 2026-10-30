import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/features/crm/domain/crm_due.dart';

// Must match the server's crm/due-date.ts and crm/plate.ts.
void main() {
  test('today is the Tashkent day (UTC+5)', () {
    expect(dayWire(crmToday(DateTime.utc(2026, 10, 30, 20))), '2026-10-31');
    expect(dayWire(crmToday(DateTime.utc(2026, 10, 30, 18, 59))), '2026-10-30');
  });

  test('due date from km: whole days rounded up, at least one, across months', () {
    final service = DateTime.utc(2026, 10, 30);
    expect(dayWire(dueFromKm(service, 5000, 120)), '2026-12-11'); // 41.67 → 42 days
    expect(dayWire(dueFromKm(service, 10, 500)), '2026-10-31');
    expect(dayWire(dueFromKm(DateTime.utc(2026, 12, 31), 100, 100)), '2027-01-01');
  });

  test('days until and stages', () {
    final today = DateTime.utc(2026, 10, 30);
    expect(daysUntil(DateTime.utc(2026, 11, 2), today: today), 3);
    expect(daysUntil(DateTime.utc(2026, 10, 28), today: today), -2);
    expect(dueStage(-1), DueStage.overdue);
    expect(dueStage(0), DueStage.soon);
    expect(dueStage(3), DueStage.soon);
    expect(dueStage(4), DueStage.later);
  });

  test('a picked local date keeps its calendar day', () {
    expect(dayWire(DateTime(2026, 12, 11, 23, 30)), '2026-12-11');
  });

  test('plates: validation and display', () {
    expect(isValidPlate('01 a 123-bc'), isTrue);
    expect(isValidPlate('01A'), isFalse);
    expect(isValidPlate('01A#123'), isFalse);
    expect(formatPlate('01A123BC'), '01 A 123 BC');
    expect(formatPlate('10123ABC'), '10 123 ABC');
    expect(formatPlate('XYZ12'), 'XYZ12');
  });
}
