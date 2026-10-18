import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/widgets/highlight_text.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_actions.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';

/// Products of one shop within a result list, in result order.
class SearchShopGroup {
  SearchShopGroup({required this.sellerId, required this.name, required this.products});

  final String sellerId;
  final String name;
  final List<StorefrontProduct> products;

  String? get imageUrl => products.map((p) => p.imageUrl).firstWhere((u) => u != null, orElse: () => null);

  static List<SearchShopGroup> of(List<StorefrontProduct> products) {
    final groups = <String, SearchShopGroup>{};
    for (final product in products) {
      groups
          .putIfAbsent(
            product.sellerId,
            () => SearchShopGroup(sellerId: product.sellerId, name: shopNameOf(product), products: []),
          )
          .products
          .add(product);
    }
    return groups.values.toList();
  }
}

/// Store name, else the owner's name.
String shopNameOf(StorefrontProduct product) =>
    (product.storeName?.trim().isNotEmpty ?? false) ? product.storeName!.trim() : product.sellerName;

/// "RECENTLY SEARCHED" — spaced caps label followed by a hairline.
class SearchSectionLabel extends StatelessWidget {
  const SearchSectionLabel({required this.text, this.trailing, this.caps = true, super.key});

  final String text;
  final Widget? trailing;
  final bool caps;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: LayoutBuilder(
        // The label takes what it needs (at most 3/4 of the row); the
        // hairline always runs to the edge.
        builder: (context, constraints) => Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.75),
              child: Text(
                caps ? text.toUpperCase() : text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: caps ? 13 : 14.5,
                  fontWeight: caps ? FontWeight.w800 : FontWeight.w700,
                  letterSpacing: caps ? 1.6 : 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: colors.outline, height: 1)),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Outlined pill (recent search / category) with an optional leading icon.
class SearchPill extends StatelessWidget {
  const SearchPill({required this.label, required this.onTap, this.icon, super.key});

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Material(
      color: colors.sheet,
      shape: StadiumBorder(side: BorderSide(color: colors.outline, width: 1.2)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: colors.textSecondary), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Suggestion row: round photo, highlighted title, subtitle, optional trailing.
class SuggestionRow extends StatelessWidget {
  const SuggestionRow({
    required this.title,
    required this.query,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
    this.icon = Icons.shopping_bag_outlined,
    this.square = false,
    this.highlighted = false,
    this.trailing,
    super.key,
  });

  final String title;
  final String query;
  final String subtitle;
  final String? imageUrl;
  final IconData icon;
  final bool square;

  /// The reference's grey "search for this" row.
  final bool highlighted;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final image = SizedBox(
      width: 60,
      height: 60,
      child: square
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: StorefrontImage(url: imageUrl, icon: icon, iconSize: 24),
            )
          : ClipOval(
              child: StorefrontImage(url: imageUrl, icon: icon, iconSize: 24),
            ),
    );
    return Material(
      color: highlighted ? colors.field : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: highlighted ? 12 : 0, vertical: 8),
          child: Row(
            children: [
              image,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      highlightMatches(
                        title,
                        highlighted ? '' : query,
                        base: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16.5,
                          fontWeight: highlighted ? FontWeight.w800 : FontWeight.w500,
                        ),
                        match: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// The reference's "Food you ❤, on time" wait screen: a spinning yellow arc
/// around the brand bag.
class SearchingView extends StatelessWidget {
  const SearchingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(color: colors.field, shape: BoxShape.circle),
                  child: Icon(Icons.shopping_bag_rounded, size: 58, color: colors.accentText),
                ),
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    color: AppColors.brandYellow,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            context.l10n.sfSearching,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ).animate().fadeIn(duration: AppMotion.standard),
    );
  }
}

/// Filter chip of the results bar. [onClear] shows a trailing ✕ (the
/// reference's selected "Tangy ✕").
class ResultFilterChip extends StatelessWidget {
  const ResultFilterChip({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.accent = false,
    this.icon,
    this.trailingIcon,
    this.onClear,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  /// Gold-text style for the category chips (the reference's coloured chips).
  final bool accent;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final borderColor = selected
        ? AppColors.brandAmber
        : accent
        ? AppColors.brandAmber.withValues(alpha: 0.45)
        : colors.outline;
    final textColor = accent || selected ? colors.accentText : colors.textPrimary;
    return Material(
      color: selected ? AppColors.brandYellow.withValues(alpha: 0.16) : colors.sheet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: textColor), const SizedBox(width: 6)],
              Text(
                label,
                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              if (trailingIcon != null) ...[const SizedBox(width: 4), Icon(trailingIcon, size: 20, color: textColor)],
              if (onClear != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close_rounded, size: 18, color: textColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The reference's dish card: name/price on the left, photo with an
/// overlapping ADD button on the right. The coloured square shows stock
/// (green = available, red = sold out) where the reference shows veg/non-veg.
class SearchProductCard extends StatelessWidget {
  const SearchProductCard({required this.product, required this.query, super.key});

  final StorefrontProduct product;
  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final available = product.stock > 0;
    final stockColor = available ? colors.success : Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark ? colors.field : colors.sheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: colors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 156,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 8),
                        Text.rich(
                          highlightMatches(
                            product.name,
                            query,
                            base: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                            match: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          available ? l10n.sfInStock(stockLabel(product)) : l10n.sfOutOfStock,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: available ? colors.textSecondary : stockColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          CurrencyFormatter.format(product.price, product.currency),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 136,
                  height: 156,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(width: 136, height: 136, child: StorefrontImage(url: product.imageUrl)),
                      ),
                      Positioned(bottom: 0, child: AddToCartButton(product: product, width: 112)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shop row of the "Do'konlar" tab (the reference's featured restaurant row).
class SearchShopRow extends StatelessWidget {
  const SearchShopRow({required this.group, required this.onTap, super.key});

  final SearchShopGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final prices = group.products.map((p) => p.price).toList()..sort();
    final currency = group.products.first.currency;
    final priceText = prices.first == prices.last
        ? CurrencyFormatter.format(prices.first, currency)
        : '${CurrencyFormatter.format(prices.first, currency)} – ${CurrencyFormatter.format(prices.last, currency)}';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 118,
                height: 128,
                child: StorefrontImage(url: group.imageUrl, icon: Icons.storefront_rounded),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textPrimary, fontSize: 19, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 16, color: colors.success),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          l10n.sfShopMatches(group.products.length),
                          style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.products.map((p) => p.name).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    priceText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Big photo card of the shops carousel (the reference's ad carousel).
class SearchShopBanner extends StatelessWidget {
  const SearchShopBanner({required this.group, required this.onTap, super.key});

  final SearchShopGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 290,
          child: Stack(
            fit: StackFit.expand,
            children: [
              StorefrontImage(url: group.imageUrl, icon: Icons.storefront_rounded, iconSize: 48),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.35, 1],
                    colors: [Colors.transparent, Color(0xE6000000)],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 6, 12, 6),
                  decoration: const BoxDecoration(
                    color: AppColors.brandYellow,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                  ),
                  child: Text(
                    l10n.sfShopMatches(group.products.length).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: BrandTheme.fontFamily,
                      color: AppColors.onBrand,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Text(
                  group.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: BrandTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
