import 'package:bsmart/features/products/domain/entities/product.dart';

/// The product's retail ("Chakana") price when it has a usable one, else null.
double? retailPriceOf(Product product) {
  final retail = product.retailPrice;
  return retail != null && retail > 0 ? retail : null;
}

/// Price a product line is charged at. A special customer ("Maxsus mijoz") always pays the
/// product's retail price when it has one; everyone else pays [Product.price]. Mirrors the
/// server's `lineUnitPrice` (Optom_Savdo `sale/special-pricing.ts`), which enforces the same rule
/// on every sale whatever the app sends — this only keeps the totals on screen equal to it.
double effectiveUnitPrice(Product product, {required bool specialCustomer}) {
  if (specialCustomer) {
    final retail = retailPriceOf(product);
    if (retail != null) return retail;
  }
  return product.price;
}
