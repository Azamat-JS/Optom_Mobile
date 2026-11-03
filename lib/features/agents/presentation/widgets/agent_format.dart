import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/l10n/app_localizations.dart';

/// "dd.MM.yyyy HH:mm", like the sales screens.
final agentDateFormat = DateFormat('dd.MM.yyyy HH:mm');

/// "12 dona" / "2.5 kg" — whole numbers without decimals, fractions up to 3 places.
String agentQty(double value, [ProductUnit? unit]) {
  final number = value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');
  return unit == null ? number : '$number ${unit.shortLabel}';
}

/// The owner's agent price (mirrors the server's `agentPriceRange`): agents sell at [price] with a
/// discount of at most [discountPercent], so between the returned min and [price].
({double min, double max}) agentPriceRange(double price, double discountPercent) {
  final max = (price * 100).roundToDouble() / 100;
  final min = (max * (100 - discountPercent) / 100 * 100).roundToDouble() / 100;
  return (min: min, max: max);
}

/// A discount the server accepts: 0–100 %, at most two decimals.
bool agentDiscountValid(double v) => v >= 0 && v <= 100 && ((v * 100).roundToDouble() - v * 100).abs() < 1e-6;

/// "50 000 so'm · −10% gacha" — the owner's price and the discount agents may give off it.
String agentPriceText(AppLocalizations l10n, String price, double discountPercent) =>
    discountPercent > 0 ? '$price · ${l10n.ownerDiscountUpTo(agentQty(discountPercent))}' : price;
