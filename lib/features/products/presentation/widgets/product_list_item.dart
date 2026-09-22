import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';

class ProductListItem extends StatelessWidget {
  const ProductListItem({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.primaryImage?.url;
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: imageUrl != null
              ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
              : Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.inventory_2_outlined),
                ),
        ),
      ),
      title: Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: product.isActive ? null : const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      subtitle: Text(
        '${product.stock.toStringAsFixed(product.unit?.isWeighable ?? false ? 2 : 0)} ${product.unit?.label ?? ''}'
        '${product.category != null ? ' • ${product.category!.name}' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        CurrencyFormatter.format(product.price, product.currency),
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
