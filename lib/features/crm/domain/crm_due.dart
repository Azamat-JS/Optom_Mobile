/// CRM day and plate helpers. Due dates are calendar days in Uzbekistan time, stored at UTC
/// midnight — the same rules as the server's `crm/due-date.ts` and `crm/plate.ts`. Pure.
library;

/// Uzbekistan has no DST: always UTC+5.
const _tashkentOffset = Duration(hours: 5);

/// Today in Tashkent, as UTC midnight.
DateTime crmToday([DateTime? now]) {
  final t = (now ?? DateTime.now()).toUtc().add(_tashkentOffset);
  return DateTime.utc(t.year, t.month, t.day);
}

/// A calendar day picked in the UI (any time zone) as UTC midnight of that same date.
DateTime asDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// "2026-12-11".
String dayWire(DateTime day) {
  final d = asDay(day);
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Days from today (negative = overdue).
int daysUntil(DateTime due, {DateTime? today}) => asDay(due).difference(today ?? crmToday()).inDays;

/// Whole days, rounded up, at least one — mirrors `dueDateFromKm` on the server.
DateTime dueFromKm(DateTime serviceDate, int intervalKm, int dailyKm) {
  final days = (intervalKm / dailyKm).ceil();
  return asDay(serviceDate).add(Duration(days: days < 1 ? 1 : days));
}

/// overdue < 0 ≤ soon (≤ 3 days, when alerts go out) < later.
enum DueStage { overdue, soon, later }

DueStage dueStage(int days) => days < 0
    ? DueStage.overdue
    : days <= 3
        ? DueStage.soon
        : DueStage.later;

String _plateKey(String input) => input.toUpperCase().replaceAll(RegExp(r'[\s\-.]'), '');

/// Mirrors the server's `normalizePlate`: 4–12 letters/digits after dropping spaces, dashes, dots.
bool isValidPlate(String input) => RegExp(r'^[A-Z0-9]{4,12}$').hasMatch(_plateKey(input));

/// "01A123BC" → "01 A 123 BC" (private car), "01123ABC" → "01 123 ABC" (company), else as stored.
String formatPlate(String plate) {
  final personal = RegExp(r'^(\d{2})([A-Z])(\d{3})([A-Z]{2})$').firstMatch(plate);
  if (personal != null) return [for (var i = 1; i <= 4; i++) personal.group(i)].join(' ');
  final company = RegExp(r'^(\d{2})(\d{3})([A-Z]{3})$').firstMatch(plate);
  if (company != null) return [for (var i = 1; i <= 3; i++) company.group(i)].join(' ');
  return plate;
}
