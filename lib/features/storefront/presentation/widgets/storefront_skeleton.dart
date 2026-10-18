import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:bsmart/core/theme/brand_theme.dart';

/// Shimmering placeholders while the feed loads (the reference's grey
/// skeleton): a rail of small cards, then two big cards.
class StorefrontFeedSkeleton extends StatelessWidget {
  const StorefrontFeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    Widget box({double? width, required double height, double radius = 20}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(radius)),
    );

    return Shimmer.fromColors(
      baseColor: colors.field,
      highlightColor: colors.sheet,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            box(height: 52, radius: 26),
            const SizedBox(height: 16),
            SizedBox(
              height: 186,
              // Wider than the screen on purpose (peeking third card): scroll
              // view only to clip, never scrolled.
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++) ...[box(width: 150, height: 186), if (i < 2) const SizedBox(width: 12)],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            box(width: 180, height: 22, radius: 8),
            const SizedBox(height: 10),
            box(width: 120, height: 16, radius: 8),
            const SizedBox(height: 18),
            box(height: 210, radius: 24),
            const SizedBox(height: 18),
            box(height: 210, radius: 24),
          ],
        ),
      ),
    );
  }
}
