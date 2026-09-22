/// A snapshot line item — `productName`/`productSku`/`productUnit` are
/// captured at order-creation time and never change even if the underlying
/// `Product` is later edited or deleted (`productId` is then null-able).
class OrderItem {
  const OrderItem({
    this.productId,
    required this.productName,
    this.productSku,
    this.productUnit,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.total,
  });

  final String? productId;
  final String productName;
  final String? productSku;
  final String? productUnit;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double total;
}
