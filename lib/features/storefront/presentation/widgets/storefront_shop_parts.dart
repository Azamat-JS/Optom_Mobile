import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_branch.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/widgets/highlight_text.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_actions.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';

/// One category block of the shop menu.
class ShopSection {
  const ShopSection({required this.title, required this.products});

  final String title;
  final List<StorefrontProduct> products;
}

/// Bottom colour of the shop header gradient; [ShopSearchHeader] continues
/// it (with the rounded bottom) until it pins.
const shopHeaderTail = Color(0xFF231A07);

/// Dark top of the shop page (the reference's restaurant header): back and
/// call buttons, then a white card with categories, name, branch picker,
/// product count and the owner row. [notice] is shown on the dark strip
/// under the card.
class ShopHeader extends StatelessWidget {
  const ShopHeader({
    required this.name,
    required this.categoriesLine,
    required this.branchName,
    required this.branchAddress,
    required this.canPickBranch,
    required this.onPickBranch,
    required this.productCount,
    required this.ownerName,
    required this.ownerPhone,
    required this.onCall,
    this.notice,
    this.onNoticeTap,
    super.key,
  });

  final String name;
  final String? categoriesLine;
  final String? branchName;
  final String? branchAddress;
  final bool canPickBranch;
  final VoidCallback onPickBranch;
  final int? productCount;
  final String? ownerName;
  final String? ownerPhone;
  final VoidCallback? onCall;
  final String? notice;
  final VoidCallback? onNoticeTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ink, shopHeaderTail],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  if (onCall != null)
                    _CircleButton(icon: Icons.call_rounded, tooltip: l10n.sfCallShop, onPressed: onCall!),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: BoxDecoration(
                color: colors.sheet,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (categoriesLine != null)
                              Text(
                                categoriesLine!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: colors.accentText, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.15,
                              ),
                            ),
                            if (branchName != null) ...[
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: canPickBranch ? onPickBranch : null,
                                borderRadius: BorderRadius.circular(8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 17, color: colors.textSecondary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        branchName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (canPickBranch)
                                      Icon(Icons.arrow_drop_down_rounded, size: 26, color: colors.textSecondary),
                                  ],
                                ),
                              ),
                            ],
                            if (branchAddress != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 21, top: 1),
                                child: Text(
                                  branchAddress!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (productCount != null) ...[
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: colors.success, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$productCount',
                                    style: const TextStyle(
                                      fontFamily: BrandTheme.fontFamily,
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.shopping_bag_rounded, size: 16, color: Colors.white),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.sfProductsShort,
                              style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (ownerName != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: colors.outline),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.brandYellow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: AppColors.onBrand),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ownerName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                ownerPhone ?? l10n.sfShopOwner,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onCall != null)
                          IconButton(
                            onPressed: onCall,
                            tooltip: l10n.sfCallShop,
                            icon: Icon(Icons.call_rounded, color: colors.success),
                            style: IconButton.styleFrom(
                              side: BorderSide(color: colors.success.withValues(alpha: 0.5)),
                              fixedSize: const Size(46, 46),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.06, end: 0, curve: AppMotion.emphasized),
            if (notice != null)
              InkWell(
                onTap: onNoticeTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Text(
                    notice!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: BrandTheme.fontFamily,
                      color: AppColors.brandYellow,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        fixedSize: const Size(48, 48),
      ),
    );
  }
}

/// Pinned search field + filter chips. Its top [topInset] (status bar
/// height) keeps the bar readable once pinned; until then that strip is
/// painted as the dark header's rounded tail, so it reads as part of it.
class ShopSearchHeader extends SliverPersistentHeaderDelegate {
  const ShopSearchHeader({required this.topInset, required this.child, required this.background});

  static const contentHeight = 140.0;

  final double topInset;
  final Widget child;
  final Color background;

  @override
  double get minExtent => contentHeight + topInset;

  @override
  double get maxExtent => contentHeight + topInset;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => ColoredBox(
    color: background,
    child: Column(
      children: [
        AnimatedContainer(
          duration: AppMotion.fast,
          height: topInset,
          decoration: BoxDecoration(
            color: overlapsContent ? background : shopHeaderTail,
            borderRadius: overlapsContent ? null : const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
        ),
        Expanded(child: child),
      ],
    ),
  );

  @override
  bool shouldRebuild(covariant ShopSearchHeader oldDelegate) => true;
}

/// "Soatlar (5) ⌃" — tap collapses or expands the section. Fixed [height],
/// which the menu jump relies on.
class ShopSectionHeader extends StatelessWidget {
  const ShopSectionHeader({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onToggle,
    super.key,
  });

  static const height = 62.0;

  final String title;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Semantics(
      button: true,
      expanded: expanded,
      child: InkWell(
        onTap: onToggle,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colors.outline)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$title ($count)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0 : 0.5,
                duration: AppMotion.standard,
                child: Icon(Icons.keyboard_arrow_up_rounded, size: 30, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-column menu card (the reference's dish tile): square photo, stock
/// square, name, price and a full-width ADD.
class ShopProductCard extends StatelessWidget {
  const ShopProductCard({required this.product, required this.query, required this.width, super.key});

  /// Card height for a given card width; the grid uses it as a fixed extent.
  static double heightFor(double width) => width + 154;

  final StorefrontProduct product;
  final String query;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final available = product.stock > 0;
    final stockColor = available ? colors.success : Theme.of(context).colorScheme.error;
    return GestureDetector(
      onTap: () => context.push(RouteNames.customerProductDetail(product.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: width,
              height: width,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: available
                        ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                        : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    child: StorefrontImage(url: product.imageUrl),
                  ),
                  Positioned(top: 8, right: 8, child: FavoriteHeart(productId: product.id, size: 20)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: stockColor, width: 1.5),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: stockColor, shape: BoxShape.circle),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  available ? stockLabel(product) : context.l10n.sfOutOfStock,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: available ? colors.textSecondary : stockColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 42,
            child: Text.rich(
              highlightMatches(
                product.name,
                query,
                base: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
                match: const TextStyle(fontWeight: FontWeight.w800),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    CurrencyFormatter.format(product.price, product.currency),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: BrandTheme.fontFamily,
                      color: AppColors.onBrand,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AddToCartButton(product: product, width: width),
        ],
      ),
    );
  }
}

/// The reference's outlet sheet: current branch highlighted, the others as
/// tappable cards. Pops the chosen branch id.
class BranchSheet extends StatelessWidget {
  const BranchSheet({required this.branches, required this.currentId, super.key});

  final List<StorefrontBranch> branches;
  final String? currentId;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    final current = branches.where((b) => b.id == currentId).firstOrNull ?? branches.first;
    final others = branches.where((b) => b.id != current.id).toList();

    Widget card(StorefrontBranch branch, {required bool selected}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? AppColors.brandYellow.withValues(alpha: 0.14) : colors.sheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? AppColors.brandAmber : colors.outline, width: selected ? 1.6 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(branch.id),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      if (branch.address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: colors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                branch.address!,
                                style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                  color: selected ? AppColors.brandAmber : colors.textSecondary,
                  size: selected ? 26 : 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(l10n.sfChooseBranch, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 18),
          Text(
            l10n.sfCurrentBranch,
            style: TextStyle(color: colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          card(current, selected: true),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.sfOtherBranches,
              style: TextStyle(color: colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final branch in others) card(branch, selected: false),
          ],
        ],
      ),
    );
  }
}

/// Round black "MENYU" button (the reference's ITEMS button).
class ShopMenuButton extends StatelessWidget {
  const ShopMenuButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: Colors.black54,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 82,
          height: 82,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 26),
              const SizedBox(height: 4),
              Text(
                context.l10n.sfMenu,
                style: const TextStyle(
                  fontFamily: BrandTheme.fontFamily,
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Black panel listing the sections with their counts (the reference's menu
/// popup). Pops the chosen section index.
class ShopMenuPanel extends StatelessWidget {
  const ShopMenuPanel({required this.sections, super.key});

  final List<ShopSection> sections;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6, maxWidth: 340),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 14),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            final style = TextStyle(
              fontFamily: BrandTheme.fontFamily,
              color: Colors.white,
              fontSize: 18,
              fontWeight: index == 0 ? FontWeight.w800 : FontWeight.w500,
            );
            return InkWell(
              onTap: () => Navigator.of(context).pop(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(section.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
                    ),
                    const SizedBox(width: 16),
                    Text('${section.products.length}', style: style),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
