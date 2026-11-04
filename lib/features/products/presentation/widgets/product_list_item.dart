import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// A product row card: photo, name, stock · category, price. Out of stock
/// shows in red; an inactive product is dimmed with a tag.
///
/// In the list's selection mode ([selectionMode]) a tick sits on the photo
/// and a [selected] card is outlined in brand yellow.
class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.product,
    required this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = Theme.of(context).colorScheme.error;
    final weighable = product.unit?.isWeighable ?? false;
    final stock = '${product.stock.toStringAsFixed(weighable ? 2 : 0)} ${product.unit?.shortLabel ?? ''}'.trim();
    final thumb = DashThumb(url: product.primaryImage?.url, size: 52);
    return DashListCard(
      onTap: onTap,
      onLongPress: onLongPress,
      outlineColor: selected ? AppColors.brandYellow : null,
      dimmed: !product.isActive,
      leading: selectionMode
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                thumb,
                Positioned(right: -4, top: -4, child: _SelectionTick(selected: selected)),
              ],
            )
          : thumb,
      title: product.name,
      subtitle: [
        if (product.stock > 0) l10n.posStockLeft(stock),
        if (product.category != null) product.category!.name,
      ].join(' · '),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyFormatter.format(product.price, product.currency),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          if (!product.isActive) ...[const SizedBox(height: 4), DashTag(label: l10n.commonInactive, color: error)],
          if (product.isActive && product.stock <= 0) ...[
            const SizedBox(height: 4),
            DashTag(label: l10n.posOutOfStock, color: error),
          ],
        ],
      ),
    );
  }
}

/// Round tick on the photo: filled yellow when selected, an empty ring otherwise.
class _SelectionTick extends StatelessWidget {
  const _SelectionTick({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.brandYellow : DashColors.card(context),
        border: Border.all(color: selected ? AppColors.brandYellow : colors.textMuted, width: 2),
      ),
      child: selected ? const Icon(Icons.check_rounded, size: 16, color: AppColors.onBrand) : null,
    );
  }
}
