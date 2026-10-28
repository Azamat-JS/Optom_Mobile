import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/product_unit.dart';

/// "dd.MM.yyyy HH:mm", like the sales screens.
final agentDateFormat = DateFormat('dd.MM.yyyy HH:mm');

/// "12 dona" / "2.5 kg" — whole numbers without decimals, fractions up to 3 places.
String agentQty(double value, [ProductUnit? unit]) {
  final number = value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');
  return unit == null ? number : '$number ${unit.shortLabel}';
}
