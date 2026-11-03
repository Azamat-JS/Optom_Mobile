import 'dart:math' as math;

import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/sales/domain/pricing/special_pricing.dart';

// Mirrors Optom_Savdo's `sale/discount-limit.ts`: an owner may cap how much (in %) a product can be
// sold below its price. The server enforces it on every sale; these keep the screens from offering
// more than it accepts. See Optom_Savdo CLAUDE.md "Product Discount Limit".

double _round2(double v) => (v * 100).roundToDouble() / 100;

// Rounding toward the limit, so a value we offer never lands a hair past it.
double _floor2(double v) => (v * 100 + 1e-6).floorToDouble() / 100;

/// A percent the server accepts: 0–100, at most two decimals.
bool isValidDiscountPercent(double v) =>
    v.isFinite && v >= 0 && v <= 100 && ((v * 100).roundToDouble() - v * 100).abs() < 1e-6;

/// The product's discount limit in %, or null when the owner set none (no limit).
double? discountLimitOf(Product product) {
  final pct = product.discountPercent;
  return pct?.clamp(0, 100).toDouble();
}

/// The lowest per-unit price the product may be sold at (a retail price the owner set always
/// counts), or null for no limit.
double? minUnitPrice(Product product) {
  final pct = discountLimitOf(product);
  if (pct == null) return null;
  final floor = product.price * (100 - pct) / 100;
  final retail = retailPriceOf(product);
  return retail != null ? math.min(floor, retail) : floor;
}

/// The most % a line priced at [unitPrice] may take off (null = no limit; 0 = none at all).
double? maxLineDiscountPercent(Product product, double unitPrice) {
  final min = minUnitPrice(product);
  if (min == null) return null;
  if (unitPrice <= 0) return 0;
  return math.max(0, _floor2((1 - min / unitPrice) * 100));
}

/// A line's discount amount for a percent, rounded to cents (what's sent as `discount`).
double lineDiscountAmount(double quantity, double unitPrice, double percent) =>
    percent > 0 ? _round2(quantity * unitPrice * percent / 100) : 0;

class LimitLine {
  const LimitLine({required this.product, required this.quantity, required this.total});

  final Product? product;
  final double quantity;

  /// The line's total after its own discount.
  final double total;
}

/// The largest sale-level discount the lines allow. The server spreads it over the lines in
/// proportion to their totals, so each limited line can only take its own room above its floor.
/// Null = no limited line.
double? maxSaleDiscount(List<LimitLine> lines) {
  final subtotal = lines.fold<double>(0, (s, l) => s + l.total);
  double? max;
  for (final l in lines) {
    final product = l.product;
    if (product == null || l.total <= 0) continue;
    final min = minUnitPrice(product);
    if (min == null) continue;
    final room = math.max(0, l.total - min * l.quantity);
    final allowed = room * subtotal / l.total;
    max = max == null ? allowed : math.min(max, allowed);
  }
  return max == null ? null : math.max(0, _floor2(max));
}
