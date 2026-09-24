class RestaurantOrderItem {
  const RestaurantOrderItem({
    required this.id,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  final String id;
  final String? productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String? notes;

  double get total => quantity * unitPrice;
}
