import 'package:flutter/material.dart';

/// The "BSM" logo mark (transparent PNG cut from the brand artwork). Made for
/// dark backgrounds — the white "S" disappears on light ones.
///
/// Wrapped in a [Hero] so it glides from the splash screen into the auth hero.
class BrandMark extends StatelessWidget {
  const BrandMark({this.width = 160, super.key});

  static const asset = 'assets/images/bsmart_mark.png';
  static const heroTag = 'bsmart-brand-mark';

  /// Width/height of the artwork (896 × 296).
  static const aspectRatio = 896 / 296;

  final double width;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Image.asset(
        asset,
        width: width,
        height: width / aspectRatio,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'bsmart',
      ),
    );
  }
}
