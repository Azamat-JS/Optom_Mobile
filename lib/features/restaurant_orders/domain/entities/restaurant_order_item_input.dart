/// Mirrors `RestaurantOrderItemInputDto` — either `productId` (a real menu
/// item) or `productName`+`unitPrice` (a manual/custom line) must be set.
class RestaurantOrderItemInput {
  const RestaurantOrderItemInput({
    this.productId,
    this.productName,
    required this.quantity,
    this.unitPrice,
    this.notes,
  });

  final String? productId;
  final String? productName;
  final int quantity;
  final double? unitPrice;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
        if (productId != null) 'productId': productId,
        if (productName != null) 'productName': productName,
        'quantity': quantity,
        if (unitPrice != null) 'unitPrice': unitPrice,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}
