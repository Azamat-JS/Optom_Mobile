import 'package:bsmart/core/enums/currency.dart';

/// A snapshot of one cart line at park-time — never re-priced from the live
/// `Product` on restore (`productName`/`unitPrice` are frozen copies, per
/// `SharedCartItemInputDto`). The caller re-fetches the live `Product` by
/// [productId] separately when resuming, to rebuild a real `PosCartLine`.
class SharedCartItem {
  const SharedCartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  });

  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discount;

  double get total => quantity * unitPrice - discount;
}

/// A parked POS cart (`GET/POST/DELETE /shared-cart`) — an in-progress
/// register transaction saved for later, shared by the owner and every admin
/// under the same tenant while the same store is active (see
/// `TenantFilter.requireStore`). Identified only by time + contents, never a
/// customer identity — matches the reference web app's own model exactly.
class SharedCart {
  const SharedCart({
    required this.id,
    required this.currency,
    required this.items,
    required this.customAmount,
    required this.saleDiscount,
    required this.createdAt,
  });

  final String id;
  final Currency currency;
  final List<SharedCartItem> items;
  final double customAmount;
  final double saleDiscount;
  final DateTime createdAt;

  double get total =>
      (items.fold<double>(0, (sum, item) => sum + item.total) + customAmount - saleDiscount).clamp(0, double.infinity);
}
