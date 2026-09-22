import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/currency.dart';

/// UZS and USD are two fully parallel, never-converted ledgers (see
/// `CLAUDE.md`) — every money figure must show its currency, and figures in
/// different currencies must never be summed/displayed as one total.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _uzsFormat = NumberFormat.decimalPattern('uz');
  static final _usdFormat = NumberFormat('#,##0.##', 'en_US');

  static String format(double amount, Currency currency) => switch (currency) {
        Currency.uzs => "${_uzsFormat.format(amount)} so'm",
        Currency.usd => '\$${_usdFormat.format(amount)}',
      };
}
