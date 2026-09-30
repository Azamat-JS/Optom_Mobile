import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';

SharedCartItem sharedCartItemFromJson(Map<String, dynamic> json) => SharedCartItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
    );

/// Parses a `SharedCart` row as returned by `shared-cart.service.ts` — unlike
/// `Product`/`Sale`, `items` is a raw `Json` column so its own fields
/// (`quantity`/`unitPrice`/`discount`) round-trip as real JSON numbers, but
/// `customAmount`/`saleDiscount` are real `Decimal` columns and still need
/// `parseDecimal`, same gotcha as everywhere else in this app.
SharedCart sharedCartFromJson(Map<String, dynamic> json) {
  final itemsJson = json['items'] as List<dynamic>? ?? const [];
  return SharedCart(
    id: json['id'] as String,
    currency: Currency.fromWire(json['currency'] as String),
    items: itemsJson.map((e) => sharedCartItemFromJson(e as Map<String, dynamic>)).toList(),
    customAmount: parseDecimal(json['customAmount'] ?? 0),
    saleDiscount: parseDecimal(json['saleDiscount'] ?? 0),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
