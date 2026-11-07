/// Why an ingredient's stock changed (mirrors `IngredientMovementType`).
enum IngredientMovementType {
  receipt,
  usage,
  restore,
  adjustment,
  waste;

  static IngredientMovementType fromWire(String value) => switch (value) {
    'RECEIPT' => IngredientMovementType.receipt,
    'USAGE' => IngredientMovementType.usage,
    'RESTORE' => IngredientMovementType.restore,
    'ADJUSTMENT' => IngredientMovementType.adjustment,
    _ => IngredientMovementType.waste,
  };
}

/// One line of an ingredient's history. [quantity] is signed (+ in, − out).
class IngredientMovement {
  const IngredientMovement({
    required this.id,
    required this.type,
    required this.quantity,
    required this.balanceAfter,
    required this.createdAt,
    required this.reversed,
    this.unitCost,
    this.note,
    this.actorName,
    this.source,
  });

  final String id;
  final IngredientMovementType type;
  final double quantity;
  final double? unitCost;
  final double balanceAfter;
  final String? note;

  /// A USAGE given back because its order was cancelled before the kitchen printed it.
  final bool reversed;
  final DateTime createdAt;
  final String? actorName;

  /// "RO-… · Plov × 2" / "SALE-… · Salat × 1" for usage rows.
  final String? source;
}
