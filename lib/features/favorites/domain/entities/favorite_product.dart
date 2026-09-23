import 'package:bsmart/core/enums/currency.dart';

/// One row of `GET /favorites` — deliberately a narrower entity than
/// `StorefrontProduct`: `favorite.service.ts`'s `list()` includes
/// `images`/`category` but not `seller`/`store` (unlike `/public/catalog`),
/// so a seller name/phone genuinely isn't available here. Tapping a favorite
/// pushes the full storefront product-detail screen (which re-fetches via
/// `/public/catalog/products/:id`) rather than trying to act on this
/// narrower shape directly.
class FavoriteProduct {
  const FavoriteProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    this.categoryName,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final Currency currency;
  final String? categoryName;
  final String? imageUrl;
}
