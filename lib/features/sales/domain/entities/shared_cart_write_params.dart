import 'package:bsmart/core/enums/currency.dart';

/// Mirrors `SharedCartItemInputDto` exactly.
class CreateSharedCartItemParams {
  const CreateSharedCartItemParams({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discount,
  });

  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double? discount;

  Map<String, dynamic> toRequestBody() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (discount != null && discount! > 0) 'discount': discount,
      };
}

/// Mirrors `CreateSharedCartDto` — `storeId` is never sent, it's derived
/// server-side from the active store, same as `RestaurantTable` creation.
class CreateSharedCartParams {
  const CreateSharedCartParams({
    required this.currency,
    required this.items,
    this.customAmount,
    this.saleDiscount,
  });

  final Currency currency;
  final List<CreateSharedCartItemParams> items;
  final double? customAmount;
  final double? saleDiscount;

  Map<String, dynamic> toRequestBody() => {
        'currency': currency.toWire(),
        'items': items.map((i) => i.toRequestBody()).toList(),
        if (customAmount != null && customAmount! > 0) 'customAmount': customAmount,
        if (saleDiscount != null && saleDiscount! > 0) 'saleDiscount': saleDiscount,
      };
}
