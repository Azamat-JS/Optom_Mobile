import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_image.dart';

/// Pinned row of round subcategory photos (the reference's Burgers / Fried
/// rice / Naan row); the selected one gets a yellow ring and a check badge.
///
/// [topInset] (the status bar height) is part of the header, so the row stays
/// visible below the status bar once it is pinned to the top.
class StorefrontCategoryCirclesHeader extends SliverPersistentHeaderDelegate {
  const StorefrontCategoryCirclesHeader({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.background,
    required this.divider,
    required this.topInset,
  });

  static const height = 126.0;

  final List<StorefrontCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;
  final Color background;
  final Color divider;
  final double topInset;

  @override
  double get minExtent => height + topInset;

  @override
  double get maxExtent => height + topInset;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        border: Border(bottom: BorderSide(color: overlapsContent || shrinkOffset > 0 ? divider : background)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(14, 12 + topInset, 14, 8),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Circle(
              label: l10n.sfAllCategories,
              imageUrl: null,
              selected: selectedId == null,
              onTap: () => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return _Circle(
            label: category.name,
            imageUrl: category.imageUrl,
            selected: selectedId == category.id,
            onTap: () => onSelected(selectedId == category.id ? null : category.id),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StorefrontCategoryCirclesHeader oldDelegate) =>
      oldDelegate.categories != categories ||
      oldDelegate.selectedId != selectedId ||
      oldDelegate.background != background ||
      oldDelegate.topInset != topInset;
}

class _Circle extends StatelessWidget {
  const _Circle({required this.label, required this.imageUrl, required this.selected, required this.onTap});

  final String label;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 78,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.standard,
                    width: 70,
                    height: 70,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? AppColors.brandAmber : Colors.transparent, width: 2.5),
                    ),
                    child: ClipOval(
                      child: imageUrl != null
                          ? StorefrontImage(url: imageUrl, icon: Icons.category_rounded, iconSize: 24)
                          : ColoredBox(
                              color: colors.field,
                              child: Icon(Icons.grid_view_rounded, color: colors.textSecondary, size: 26),
                            ),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.brandYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.sheet, width: 2),
                        ),
                        child: const Icon(Icons.check_rounded, size: 13, color: AppColors.onBrand),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? colors.accentText : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
