import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_actions.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';

/// Full-width feed card (the reference's restaurant card): big photo with a
/// stock badge and a category tab, then shop, name, price and ADD.
class StorefrontProductCard extends StatelessWidget {
  const StorefrontProductCard({required this.product, super.key});

  final StorefrontProduct product;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final outOfStock = product.stock <= 0;
    final hasPhoto = product.imageUrl != null;
    final shop = (product.storeName?.trim().isNotEmpty ?? false) ? product.storeName! : product.sellerName;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      decoration: BoxDecoration(
        // Raised surface in dark mode, where a shadow doesn't separate it.
        color: Theme.of(context).brightness == Brightness.dark ? colors.field : colors.sheet,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: AspectRatio(
                  aspectRatio: 1.75,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColorFiltered(
                        colorFilter: outOfStock
                            ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                        child: StorefrontImage(url: product.imageUrl, iconSize: 44),
                      ),
                      if (hasPhoto)
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.6, 1],
                              colors: [Colors.transparent, Color(0x99000000)],
                            ),
                          ),
                        ),
                      Positioned(top: 12, right: 12, child: FavoriteHeart(productId: product.id)),
                      Positioned(
                        left: 14,
                        bottom: 12,
                        child: _StockBadge(
                          text: outOfStock ? l10n.sfOutOfStock : l10n.sfInStock(stockLabel(product)),
                          warning: outOfStock,
                          onPhoto: hasPhoto,
                        ),
                      ),
                      if (product.categoryName != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 170),
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                            decoration: BoxDecoration(
                              color: colors.sheet,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
                            ),
                            child: Text(
                              product.categoryName!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storefront_rounded, size: 16, color: colors.accentText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            shop,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.accentText, fontSize: 13.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            CurrencyFormatter.format(product.price, product.currency),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                        AddToCartButton(product: product),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.text, required this.warning, required this.onPhoto});

  final String text;
  final bool warning;

  /// White text with a shadow over a photo; dark text on the placeholder.
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final textColor = onPhoto ? Colors.white : colors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          warning ? Icons.remove_shopping_cart_rounded : Icons.inventory_2_rounded,
          size: 16,
          color: warning ? Theme.of(context).colorScheme.error : textColor,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: BrandTheme.fontFamily,
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            shadows: onPhoto ? const [Shadow(color: Colors.black54, blurRadius: 6)] : null,
          ),
        ),
      ],
    );
  }
}
