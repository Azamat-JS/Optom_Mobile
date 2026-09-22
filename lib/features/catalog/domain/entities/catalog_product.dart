import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';

/// A product as it appears in the buyer-facing `catalog` browse — distinct
/// from `features/products`'s own `Product` (the tenant's own inventory
/// entity): this one never carries `costPrice` (the backend explicitly
/// strips it — "internal, never expose to retailers") and always carries
/// seller/store context, since a buyer is browsing someone else's stock.
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    required this.stock,
    this.unit,
    this.categoryId,
    this.categoryName,
    required this.seller,
    this.storeId,
    this.storeName,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final double price;
  final Currency currency;
  final double stock;
  final ProductUnit? unit;
  final String? categoryId;
  final String? categoryName;
  final CatalogSeller seller;
  final String? storeId;
  final String? storeName;
  final String? imageUrl;
}
