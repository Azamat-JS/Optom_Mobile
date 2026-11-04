/// Answer of `POST /products/move-to-store` (Optom_Savdo CLAUDE.md "Moving
/// Products Between Stores"): how many products went to which store.
class ProductMoveResult {
  const ProductMoveResult({required this.moved, required this.targetStoreId, required this.targetStoreName});

  final int moved;
  final String targetStoreId;
  final String targetStoreName;

  factory ProductMoveResult.fromJson(Map<String, dynamic> json) {
    final store = json['targetStore'] as Map<String, dynamic>;
    return ProductMoveResult(
      moved: (json['moved'] as num).toInt(),
      targetStoreId: store['id'] as String,
      targetStoreName: store['name'] as String,
    );
  }
}
