import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';

/// A shop (seller) as shown in the storefront's shop strip. The public
/// catalog has no shop list endpoint, so shops are derived from the products
/// already loaded — see [StorefrontShop.fromProducts].
class StorefrontShop {
  const StorefrontShop({required this.sellerId, required this.name, this.imageUrl});

  final String sellerId;

  /// Store name when the product carries one (what customers know the shop
  /// by), else the owner's name.
  final String name;

  /// First product photo of that shop, used as the card image.
  final String? imageUrl;

  /// One entry per seller, in feed order, preferring a product with a photo.
  static List<StorefrontShop> fromProducts(List<StorefrontProduct> products, {int limit = 12}) {
    final shops = <String, StorefrontShop>{};
    for (final product in products) {
      final existing = shops[product.sellerId];
      if (existing != null && existing.imageUrl != null) continue;
      final name = (product.storeName?.trim().isNotEmpty ?? false) ? product.storeName!.trim() : product.sellerName;
      shops[product.sellerId] = StorefrontShop(
        sellerId: product.sellerId,
        name: existing?.name ?? name,
        imageUrl: existing?.imageUrl ?? product.imageUrl,
      );
      if (shops.length >= limit && shops.values.every((s) => s.imageUrl != null)) break;
    }
    return shops.values.take(limit).toList();
  }
}
