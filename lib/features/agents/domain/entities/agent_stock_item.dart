import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';

/// One of the owner's products as agent screens show it — name and image come live from the
/// owner's product (or its master-catalog entry); agents never get their own product rows.
class AgentProductRef {
  const AgentProductRef({required this.id, required this.name, this.unit, this.barcode, this.imageUrl});

  final String id;
  final String name;
  final ProductUnit? unit;
  final String? barcode;
  final String? imageUrl;
}

/// The lead agent's stock of one product (`AgentProduct`), shared by its staff agents. Every sale
/// line must be priced within [minPrice]…[maxPrice] — the owner's range, enforced server-side.
class AgentStockItem {
  const AgentStockItem({
    required this.id,
    required this.currency,
    required this.stock,
    required this.minPrice,
    required this.maxPrice,
    required this.product,
  });

  final String id;
  final Currency currency;
  final double stock;
  final double minPrice;
  final double maxPrice;
  final AgentProductRef product;

  bool allows(double price) => price >= minPrice - 0.0005 && price <= maxPrice + 0.0005;
}
