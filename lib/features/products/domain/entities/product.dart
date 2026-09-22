import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/features/products/domain/entities/product_image.dart';

/// A minimal category reference embedded on a product — deliberately not
/// the `categories` feature's own `Category` entity (a feature's domain
/// should not depend on another feature's domain; each defines its own
/// lightweight view of data it embeds from elsewhere).
class ProductCategoryRef {
  const ProductCategoryRef({required this.id, required this.name, this.parentName});

  final String id;
  final String name;
  final String? parentName;
}

/// The tenant's own inventory product (`GET /products` — always scoped to
/// the caller's own `sellerId`/store; this is never a browsable market of
/// other sellers' stock, see `products_remote_data_source.dart`'s doc note).
///
/// For a catalog-linked product (`masterProductId != null`), the backend's
/// `resolveDisplay()` already fills [name]/[description]/[images]/[brand]
/// in from the linked `MasterProduct` before the JSON reaches this app — so
/// those fields are always populated here regardless of link status.
class Product {
  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.costPrice,
    required this.currency,
    required this.stock,
    this.unit,
    this.sku,
    this.barcode,
    this.plu,
    required this.isActive,
    this.expiryDate,
    this.categoryId,
    this.masterProductId,
    this.brand,
    this.category,
    this.images = const [],
  });

  final String id;
  final String name;
  final String? description;
  final double price;
  final double? costPrice;
  final Currency currency;
  final double stock;
  final ProductUnit? unit;
  final String? sku;
  final String? barcode;
  final String? plu;
  final bool isActive;
  final DateTime? expiryDate;
  final String? categoryId;
  final String? masterProductId;
  final String? brand;
  final ProductCategoryRef? category;
  final List<ProductImage> images;

  bool get isCatalogLinked => masterProductId != null;

  ProductImage? get primaryImage {
    for (final image in images) {
      if (image.isPrimary) return image;
    }
    return images.isEmpty ? null : images.first;
  }
}
