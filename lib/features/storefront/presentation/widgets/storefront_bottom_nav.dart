import 'package:flutter/material.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';

class StorefrontNavItem {
  const StorefrontNavItem({required this.icon, required this.selectedIcon, required this.label, this.badge = 0});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badge;
}

/// Storefront tab bar: the selected tab's icon sits on a yellow pill with a
/// bold label; the rest are muted.
class StorefrontBottomNav extends StatelessWidget {
  const StorefrontBottomNav({required this.items, required this.selectedIndex, required this.onSelected, super.key});

  final List<StorefrontNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.sheet,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(item: items[i], selected: i == selectedIndex, onTap: () => onSelected(i)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final StorefrontNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppMotion.standard,
              curve: AppMotion.emphasized,
              width: selected ? 58 : 40,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.brandYellow : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Badge(
                isLabelVisible: item.badge > 0,
                label: Text('${item.badge}'),
                backgroundColor: AppColors.ink,
                textColor: Colors.white,
                offset: const Offset(6, -4),
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: 24,
                  color: selected ? AppColors.onBrand : colors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? colors.textPrimary : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
