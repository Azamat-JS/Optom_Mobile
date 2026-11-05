/// Client mirror of the server's manual revenue rules (Optom_Savdo
/// `apps/server/src/sale/manual-revenue.ts`, see its CLAUDE.md "Manual Revenue"):
/// money from goods that were never entered in the app, recorded with an
/// amount, currency, payment method, an optional day and an optional customer.
/// The server re-checks all of it.
library;

/// How far back a manual revenue may be dated (the server refuses older).
const manualRevenueMaxBackdateDays = 366;

/// The largest amount a `Decimal(12, 2)` column holds.
const manualRevenueMaxAmount = 9999999999.99;

/// Uzbekistan has no DST: a business day there is always UTC+5.
const _tashkentOffset = Duration(hours: 5);

/// Today's calendar day in Tashkent, as a date-only `DateTime` (local midnight).
/// The server checks the chosen day against Tashkent, not the phone's zone.
DateTime tashkentToday([DateTime? now]) {
  final t = (now ?? DateTime.now()).toUtc().add(_tashkentOffset);
  return DateTime(t.year, t.month, t.day);
}

/// The earliest day the date picker may offer.
DateTime manualRevenueFirstDate([DateTime? now]) {
  final today = tashkentToday(now);
  return DateTime(today.year, today.month, today.day - manualRevenueMaxBackdateDays);
}

/// `YYYY-MM-DD` of a date-only value — what `POST /sales/manual-revenue` takes.
String manualRevenueDay(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

/// The `date` to send for the picked [day]: nothing for no day or today (the
/// server then books it at the moment it's saved), else the day itself.
String? manualRevenueDateParam(DateTime? day, [DateTime? now]) {
  if (day == null) return null;
  final picked = DateTime(day.year, day.month, day.day);
  return picked == tashkentToday(now) ? null : manualRevenueDay(picked);
}

/// A typed amount as a number: spaces (thousand groups) are ignored and a
/// comma works as the decimal point. `null` unless it's a positive number with
/// at most 2 decimals.
double? parseManualRevenueAmount(String raw) {
  final text = raw.replaceAll(RegExp(r'[\s  ]'), '').replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) return null;
  final value = double.parse(text);
  return value > 0 ? value : null;
}

/// Same phone rule as the server's DTO (9–15 digits, optional leading +),
/// after dropping the spaces, dashes and brackets people type.
String cleanManualRevenuePhone(String raw) => raw.replaceAll(RegExp(r'[\s()\-]'), '');

bool isValidManualRevenuePhone(String raw) => RegExp(r'^\+?\d{9,15}$').hasMatch(cleanManualRevenuePhone(raw));
