class RestaurantOrderItem {
  const RestaurantOrderItem({
    required this.id,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    this.kitchenSent = true,
  });

  final String id;
  final String? productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String? notes;

  /// Went to the kitchen (a ticket was written). False while a delivery waits for its courier or
  /// a takeaway waits for payment.
  final bool kitchenSent;

  double get total => quantity * unitPrice;
}
