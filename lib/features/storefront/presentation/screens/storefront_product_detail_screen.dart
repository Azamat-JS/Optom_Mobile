import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_cart_notifier.dart';
import 'package:bsmart/features/storefront/presentation/providers/storefront_shop_providers.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_actions.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';

/// Guest-eligible product page (`GET /public/catalog/products/:id`).
///
/// Phase 9 U2d (Swiggy dish reference): swipeable photos with page dots,
/// stock square + name + ADD/stepper, price, a short description that
/// expands, the shop card (→ shop page) and a "more from this shop" rail.
/// The favourite heart sends guests to login ([FavoriteHeart]).
class StorefrontProductDetailScreen extends StatelessWidget {
  const StorefrontProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) => Theme(
    data: BrandTheme.of(context),
    child: _DetailBody(productId: productId),
  );
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final async = ref.watch(storefrontProductProvider(productId));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The photo is under the status bar; light icons read on a dark scrim.
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: colors.sheet,
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => SafeArea(
            child: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: _RoundButton.back(context, dark: false)),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: colors.textSecondary),
                        const SizedBox(height: 12),
                        Text(l10n.commonUnknownError, style: TextStyle(color: colors.textPrimary)),
                        TextButton(
                          onPressed: () => ref.invalidate(storefrontProductProvider(productId)),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (product) => _Loaded(product: product),
        ),
        bottomNavigationBar: async.valueOrNull == null ? null : _BottomBar(product: async.value!),
      ),
    );
  }
}

class _Loaded extends ConsumerStatefulWidget {
  const _Loaded({required this.product});

  final StorefrontProduct product;

  @override
  ConsumerState<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends ConsumerState<_Loaded> {
  int _page = 0;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final images = product.images.isNotEmpty ? product.images : [?product.imageUrl];
    final available = product.stock > 0;
    final stockColor = available ? colors.success : Theme.of(context).colorScheme.error;
    final shop = shopNameOf(product);
    final description = product.description?.trim() ?? '';
    final more = ref
        .watch(shopProductsProvider((sellerId: product.sellerId, storeId: product.storeId)))
        .valueOrNull
        ?.where((p) => p.id != product.id)
        .take(10)
        .toList();
    final width = MediaQuery.sizeOf(context).width;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: width * 0.95,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (images.isEmpty)
                  const StorefrontImage(url: null, iconSize: 64)
                else
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) => StorefrontImage(url: images[i], iconSize: 64),
                  ),
                // Scrim for the status bar and the round buttons.
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Color(0x88000000), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RoundButton.back(context, dark: true),
                        const Spacer(),
                        FavoriteHeart(productId: product.id, size: 24),
                      ],
                    ),
                  ),
                ),
                // Rounded top of the sheet below, drawn here: a viewport paints
                // earlier slivers over later ones, so the sheet can't overlap.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -1,
                  height: 26,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.sheet,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 34,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < images.length; i++)
                          AnimatedContainer(
                            duration: AppMotion.fast,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _page ? 18 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: i == _page ? Colors.white : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: colors.sheet,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: stockColor, width: 1.6),
                      ),
                      child: Center(
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(color: stockColor, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        available ? l10n.sfInStock(stockLabel(product)) : l10n.sfOutOfStock,
                        style: TextStyle(
                          color: available ? colors.success : stockColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (product.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          product.categoryName!,
                          style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        CurrencyFormatter.format(product.price, product.currency),
                        style: const TextStyle(
                          fontFamily: BrandTheme.fontFamily,
                          color: AppColors.onBrand,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (product.unit != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        '/ ${product.unit!.shortLabel}',
                        style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    l10n.sfDescription,
                    style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSize(
                    duration: AppMotion.standard,
                    alignment: Alignment.topCenter,
                    child: Text(
                      description,
                      maxLines: _expanded ? null : 3,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSecondary, fontSize: 15.5, height: 1.45),
                    ),
                  ),
                  if (description.length > 120)
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          _expanded ? l10n.sfReadLess : l10n.sfReadMore,
                          style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                _ShopCard(product: product, shop: shop),
              ],
            ),
          ),
        ),
        if (more != null && more.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: SearchSectionLabel(text: l10n.sfMoreFromShop),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: more.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _MiniCard(product: more[i]).animate().fadeIn(delay: (40 * i).ms, duration: AppMotion.standard),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.product, required this.shop});

  final StorefrontProduct product;
  final String shop;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    return Material(
      color: colors.field,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(RouteNames.customerShop(product.sellerId, storeId: product.storeId, name: shop)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.storefront_rounded, color: AppColors.onBrand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textPrimary, fontSize: 16.5, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      l10n.sfOpenShop,
                      style: TextStyle(color: colors.accentText, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.product});

  final StorefrontProduct product;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return GestureDetector(
      // Replace, so back returns to where the first product was opened from.
      onTap: () => context.pushReplacement(RouteNames.customerProductDetail(product.id)),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(width: 140, height: 140, child: StorefrontImage(url: product.imageUrl)),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
            ),
            Text(
              CurrencyFormatter.format(product.price, product.currency),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sticky bottom bar: price (or what's already in the cart) + ADD/stepper.
class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.product});

  final StorefrontProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final line = ref.watch(storefrontCartProvider.select((cart) => cart.lines[product.id]));
    final quantity = line == null
        ? null
        : (line.quantity == line.quantity.roundToDouble()
              ? line.quantity.toInt().toString()
              : line.quantity.toStringAsFixed(1));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.sheet,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.format(line?.total ?? product.price, product.currency),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    if (quantity != null)
                      Text(
                        l10n.sfInCart(quantity),
                        style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
              AddToCartButton(product: product, width: 170),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton {
  static Widget back(BuildContext context, {required bool dark}) {
    final colors = BrandColors.of(context);
    return IconButton(
      onPressed: () => context.pop(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: Icon(Icons.arrow_back_rounded, color: dark ? Colors.white : colors.textPrimary),
      style: IconButton.styleFrom(
        backgroundColor: dark ? Colors.black.withValues(alpha: 0.28) : colors.field,
        fixedSize: const Size(46, 46),
      ),
    );
  }
}
