import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';

/// Photo mosaic of products (the reference's in-shop explore grid). Tiles
/// repeat in blocks of 9:
///
///   [s][s][s]      three small
///   [s][ BIG ]     two small stacked left, a big one right
///   [s][     ]
///   [ BIG ][s]     the mirror
///   [     ][s]
///
/// A partial last block falls back to rows of three. Each block is one list
/// item, so the grid stays lazy.
class StorefrontMasonry extends StatelessWidget {
  const StorefrontMasonry({required this.products, this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 24), super.key});

  static const gap = 8.0;
  static const _block = 9;

  final List<StorefrontProduct> products;
  final EdgeInsets padding;

  /// Big tiles are slots 5 and 6 of each full block of 9.
  static bool isBigSlot(int index) => index % _block == 5 || index % _block == 6;

  /// Reorders [products] so the big slots get products with a photo when
  /// there are any; everything else keeps its order.
  static List<StorefrontProduct> photosInBigSlots(List<StorefrontProduct> products) {
    final fullBlocks = products.length - products.length % _block;
    final withPhoto = [
      for (final p in products)
        if (p.imageUrl != null) p,
    ];
    final big = <StorefrontProduct>[];
    for (var i = 0; i < fullBlocks && big.length < withPhoto.length; i++) {
      if (isBigSlot(i)) big.add(withPhoto[big.length]);
    }
    final rest = [
      for (final p in products)
        if (!big.contains(p)) p,
    ];
    var b = 0;
    var r = 0;
    return [
      for (var i = 0; i < products.length; i++)
        if (i < fullBlocks && isBigSlot(i) && b < big.length) big[b++] else rest[r++],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ordered = photosInBigSlots(products);
    final blocks = <List<StorefrontProduct>>[
      for (var i = 0; i < ordered.length; i += _block) ordered.sublist(i, (i + _block).clamp(0, ordered.length)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - padding.horizontal;
        final small = (width - gap * 2) / 3;
        final big = small * 2 + gap;
        return ListView.builder(
          padding: padding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: blocks.length,
          itemBuilder: (context, index) =>
              _Block(products: blocks[index], small: small, big: big).animate().fadeIn(duration: AppMotion.standard),
        );
      },
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.products, required this.small, required this.big});

  final List<StorefrontProduct> products;
  final double small;
  final double big;

  @override
  Widget build(BuildContext context) {
    const gap = StorefrontMasonry.gap;
    Widget tile(int i, double size) => _Tile(product: products[i], width: size, height: size, large: size == big);
    Widget column(int a, int b) => Column(
      children: [
        tile(a, small),
        const SizedBox(height: gap),
        tile(b, small),
      ],
    );
    Widget row(List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: gap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: gap), children[i]],
        ],
      ),
    );

    if (products.length < 9) {
      // Partial block: plain rows of three.
      return Column(
        children: [
          for (var i = 0; i < products.length; i += 3)
            row([for (var j = i; j < (i + 3).clamp(0, products.length); j++) tile(j, small)]),
        ],
      );
    }
    return Column(
      children: [
        row([tile(0, small), tile(1, small), tile(2, small)]),
        row([column(3, 4), tile(5, big)]),
        row([tile(6, big), column(7, 8)]),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.product, required this.width, required this.height, required this.large});

  final StorefrontProduct product;
  final double width;
  final double height;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final available = product.stock > 0;
    final stockColor = available ? colors.success : Theme.of(context).colorScheme.error;
    return GestureDetector(
      onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(large ? 24 : 18),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              StorefrontImage(url: product.imageUrl, iconSize: large ? 48 : 28),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.55, 1],
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: stockColor, width: 1.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: stockColor, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: BrandTheme.fontFamily,
                          color: Colors.white,
                          fontSize: large ? 17 : 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
