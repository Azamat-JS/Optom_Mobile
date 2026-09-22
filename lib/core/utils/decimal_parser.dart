/// NestJS/Prisma serializes `Decimal` fields (money, stock quantity) as JSON
/// **strings**, not numbers — e.g. `Product.price`/`.costPrice`/`.stock`.
/// Confirmed by reading the Prisma schema + service layer directly, not
/// assumed. Every model touching a `Decimal`-backed field must parse through
/// this helper rather than casting `as num`/`as double`.
double parseDecimal(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  throw FormatException('Expected a decimal string or number, got: $value');
}

double? parseNullableDecimal(dynamic value) {
  if (value == null) return null;
  return parseDecimal(value);
}
