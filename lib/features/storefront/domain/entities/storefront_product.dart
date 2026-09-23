import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/product_unit.dart';

/// A product as it appears in the guest-eligible public storefront
/// (`GET /public/catalog/*` — no auth required). Deliberately its own entity
/// rather than a reuse of `features/catalog`'s `CatalogProduct`: that
/// feature is the *authenticated* RETAILER→SELLER B2B browse (a genuinely
/// separate bounded context — see `CLAUDE.md`'s Phase 2 plan, "own
/// publicDioProvider, no auth interceptor"), even though both endpoints
/// happen to share the same backend `productIncludes()` shape today.
/// Storefront browsing is always scoped to `sellerRole=RETAILER` — a
/// customer buys from retailers, never directly from a wholesaler.
class StorefrontProduct {
  const StorefrontProduct({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    required this.stock,
    this.unit,
    this.categoryId,
    this.categoryName,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    this.storeId,
    this.storeName,
    this.imageUrl,
    this.images = const [],
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
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String? storeId;
  final String? storeName;
  final String? imageUrl;
  final List<String> images;
}

/// `GET /public/catalog/categories` — no auth required.
class StorefrontCategory {
  const StorefrontCategory({required this.id, required this.name, this.imageUrl, this.icon, this.parentId});

  final String id;
  final String name;
  final String? imageUrl;
  final String? icon;
  final String? parentId;
}
