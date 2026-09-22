/// Mirrors the backend's Prisma `ProductUnit` enum exactly.
enum ProductUnit {
  dona,
  metr,
  litr,
  kilogram,
  gram,
  blok;

  static ProductUnit fromWire(String value) => switch (value) {
        'DONA' => ProductUnit.dona,
        'METR' => ProductUnit.metr,
        'LITR' => ProductUnit.litr,
        'KILOGRAM' => ProductUnit.kilogram,
        'GRAM' => ProductUnit.gram,
        'BLOK' => ProductUnit.blok,
        _ => throw ArgumentError('Unknown ProductUnit from backend: $value'),
      };

  String toWire() => switch (this) {
        ProductUnit.dona => 'DONA',
        ProductUnit.metr => 'METR',
        ProductUnit.litr => 'LITR',
        ProductUnit.kilogram => 'KILOGRAM',
        ProductUnit.gram => 'GRAM',
        ProductUnit.blok => 'BLOK',
      };

  /// Uzbek display label, matching the reference web app's copy.
  String get label => switch (this) {
        ProductUnit.dona => 'Dona',
        ProductUnit.metr => 'Metr',
        ProductUnit.litr => 'Litr',
        ProductUnit.kilogram => 'Kilogramm',
        ProductUnit.gram => 'Gramm',
        ProductUnit.blok => 'Blok',
      };

  /// Quantity input should accept fractional amounts for these units (a
  /// decimal keyboard + kg/g/l label) vs. an integer stepper for the rest —
  /// see the implementation plan's Milestone 2 edge cases.
  bool get isWeighable =>
      this == ProductUnit.kilogram || this == ProductUnit.gram || this == ProductUnit.litr;
}
