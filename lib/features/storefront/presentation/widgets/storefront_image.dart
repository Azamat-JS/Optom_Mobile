import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bsmart/core/theme/brand_theme.dart';

/// Network product/category photo with a neutral placeholder (no photo, still
/// loading, or failed).
class StorefrontImage extends StatelessWidget {
  const StorefrontImage({
    required this.url,
    this.icon = Icons.shopping_bag_outlined,
    this.iconSize = 32,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String? url;
  final IconData icon;
  final double iconSize;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final placeholder = ColoredBox(
      color: colors.field,
      child: Center(
        child: Icon(icon, size: iconSize, color: colors.textMuted),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, _) => ColoredBox(color: colors.field),
      errorWidget: (_, _, _) => placeholder,
    );
  }
}
