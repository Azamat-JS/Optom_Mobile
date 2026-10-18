import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_shop.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';

/// Panel colour under the category tabs; the selected tab shares it so the
/// two read as one shape (the reference's purple panel).
const _panelColor = AppColors.inkRaised;
const _shopCardColor = Color(0xFF242833);

/// Dark top of the storefront home: greeting + profile button, top-level
/// category tabs, then a rounded panel with the search field and the shop
/// strip.
class StorefrontHero extends StatelessWidget {
  const StorefrontHero({
    required this.greeting,
    required this.onProfile,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onSearchTap,
    required this.searchHints,
    required this.shops,
    required this.selectedSellerId,
    required this.onShopSelected,
    super.key,
  });

  final String greeting;
  final VoidCallback onProfile;

  /// Top-level categories (`parentId == null`).
  final List<StorefrontCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  /// Opens the search screen (the field here is only a button).
  final VoidCallback onSearchTap;

  /// Rotated through the search placeholder ("«Non» ni qidiring").
  final List<String> searchHints;
  final List<StorefrontShop> shops;
  final String? selectedSellerId;
  final ValueChanged<String?> onShopSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppColors.ink,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: BrandTheme.fontFamily,
                            color: AppColors.brandYellow,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.sfGreetingSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: BrandTheme.fontFamily,
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onProfile,
                    tooltip: l10n.navProfile,
                    icon: const Icon(Icons.person_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                      fixedSize: const Size(48, 48),
                    ),
                  ),
                ],
              ),
            ),
            if (categories.isNotEmpty)
              _CategoryTabs(categories: categories, selectedId: selectedCategoryId, onSelected: onCategorySelected),
            Container(
              decoration: const BoxDecoration(
                color: _panelColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _SearchField(onTap: onSearchTap, hints: searchHints),
                  ),
                  if (shops.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      l10n.sfShops,
                      style: const TextStyle(
                        fontFamily: BrandTheme.fontFamily,
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 16),
                        itemCount: shops.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final shop = shops[index];
                          final selected = shop.sellerId == selectedSellerId;
                          return _ShopCard(
                            shop: shop,
                            selected: selected,
                            onTap: () => onShopSelected(selected ? null : shop.sellerId),
                          ).animate().fadeIn(delay: (40 * index).ms, duration: AppMotion.standard);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The reference's Food/Instamart/Dineout tabs: slanted, rounded-top tabs;
/// the selected one merges into the panel below.
class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.categories, required this.selectedId, required this.onSelected});

  final List<StorefrontCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 2),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryTab(
              label: l10n.sfAllCategories,
              imageUrl: null,
              icon: Icons.grid_view_rounded,
              selected: selectedId == null,
              onTap: () => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return _CategoryTab(
            label: category.name,
            imageUrl: category.imageUrl,
            icon: Icons.category_rounded,
            selected: selectedId == category.id,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.imageUrl,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? imageUrl;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipPath(
          clipper: const _TabClipper(),
          child: AnimatedContainer(
            duration: AppMotion.standard,
            width: 98,
            color: selected ? _panelColor : Colors.white.withValues(alpha: 0.05),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: StorefrontImage(url: imageUrl, icon: icon, iconSize: 24),
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: selected ? AppColors.brandYellow : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon, color: selected ? AppColors.onBrand : Colors.white, size: 26),
                        ),
                ),
                const Spacer(),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: BrandTheme.fontFamily,
                    color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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

class _TabClipper extends CustomClipper<Path> {
  const _TabClipper();

  @override
  Path getClip(Size size) {
    const slant = 7.0;
    const radius = 20.0;
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, h)
      ..lineTo(slant, radius)
      ..quadraticBezierTo(slant + 1.5, 0, slant + radius, 0)
      ..lineTo(w - slant - radius, 0)
      ..quadraticBezierTo(w - slant - 1.5, 0, w - slant, radius)
      ..lineTo(w, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Search bar look-alike with a rotating "«Kategoriya» ni qidiring"
/// placeholder; tapping it opens the search screen.
class _SearchField extends StatefulWidget {
  const _SearchField({required this.onTap, required this.hints});

  final VoidCallback onTap;
  final List<String> hints;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  Timer? _timer;
  int _hintIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && widget.hints.length > 1) {
        setState(() => _hintIndex = (_hintIndex + 1) % widget.hints.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hint = widget.hints.isEmpty
        ? l10n.sfSearchHintDefault
        : l10n.sfSearchHint(widget.hints[_hintIndex % widget.hints.length]);
    return Semantics(
      button: true,
      label: l10n.sfSearchTitle,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRect(
                    child: AnimatedSwitcher(
                      duration: AppMotion.slow,
                      // New hint rises from below; the old one leaves upwards.
                      transitionBuilder: (child, animation) {
                        final incoming = child.key == ValueKey(hint);
                        final offset = Tween(
                          begin: incoming ? const Offset(0, 1) : const Offset(0, -1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: AppMotion.emphasized));
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: offset, child: child),
                        );
                      },
                      layoutBuilder: (current, previous) =>
                          Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
                      child: Text(
                        hint,
                        key: ValueKey(hint),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: BrandTheme.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop, required this.selected, required this.onTap});

  final StorefrontShop shop;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: _shopCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: selected ? AppColors.brandYellow : Colors.white.withValues(alpha: 0.06), width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 134,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                  child: SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        shop.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: BrandTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox.expand(
                        child: StorefrontImage(url: shop.imageUrl, icon: Icons.storefront_rounded),
                      ),
                    ),
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
