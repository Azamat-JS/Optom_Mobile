/// Mirrors the backend's Prisma `Currency` enum. UZS and USD are two fully
/// parallel, never-converted ledgers — never sum figures across currencies.
enum Currency {
  uzs,
  usd;

  static Currency fromWire(String value) => switch (value) {
        'UZS' => Currency.uzs,
        'USD' => Currency.usd,
        _ => throw ArgumentError('Unknown Currency from backend: $value'),
      };

  String toWire() => switch (this) {
        Currency.uzs => 'UZS',
        Currency.usd => 'USD',
      };

  String get symbol => switch (this) {
        Currency.uzs => "so'm",
        Currency.usd => '\$',
      };
}
