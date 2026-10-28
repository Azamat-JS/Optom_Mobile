import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';

/// "1 200 000 so'm · $350": so'm always (zero included, unless only dollars are owed), dollars
/// only when there are some. Never summed across currencies.
String agentMoneyBoth(MoneyByCurrency m) {
  final parts = [
    if (m.uzs > 0 || m.usd <= 0) CurrencyFormatter.format(m.uzs, Currency.uzs),
    if (m.usd > 0) CurrencyFormatter.format(m.usd, Currency.usd),
  ];
  return parts.join(' · ');
}

double agentAmountIn(MoneyByCurrency m, Currency currency) => currency == Currency.uzs ? m.uzs : m.usd;
