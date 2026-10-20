import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// A product row card: photo, name, stock · category, price. Out of stock
/// shows in red; an inactive product is dimmed with a tag.
class ProductListItem extends StatelessWidget {
  const ProductListItem({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = Theme.of(context).colorScheme.error;
    final weighable = product.unit?.isWeighable ?? false;
    final stock = '${product.stock.toStringAsFixed(weighable ? 2 : 0)} ${product.unit?.shortLabel ?? ''}'.trim();
    return DashListCard(
      onTap: onTap,
      dimmed: !product.isActive,
      leading: DashThumb(url: product.primaryImage?.url, size: 52),
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
