import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/expenditure_type.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/core/enums/payment_method.dart';
import 'package:bsmart/core/enums/product_unit.dart';
import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/sale_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/l10n/app_l10n.dart';
import 'package:bsmart/core/l10n/locale_provider.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';

void main() {
  tearDown(() => setActiveLanguageCode(defaultLanguageCode));

  test('enum labels follow the active language', () {
    setActiveLanguageCode('uz');
    expect(OrderStatus.approved.label, 'Tasdiqlangan');
    setActiveLanguageCode('ru');
    expect(OrderStatus.approved.label, 'Подтверждён');
    setActiveLanguageCode('en');
    expect(OrderStatus.approved.label, 'Approved');
  });

  test('every enum value has a non-empty label in every language', () {
    for (final code in supportedLanguageCodes) {
      setActiveLanguageCode(code);
      final labels = [
        ...OrderStatus.values.map((e) => e.label),
        ...PaymentMethod.values.map((e) => e.label),
        ...BusinessType.values.map((e) => e.label),
        ...ExpenditureType.values.map((e) => e.label),
        ...ProductUnit.values.map((e) => e.label),
        ...RestaurantOrderType.values.map((e) => e.label),
        ...RestaurantOrderStatus.values.map((e) => e.label),
        ...SaleType.values.map((e) => e.label),
        ...SaleStatus.values.map((e) => e.label),
        ...DebtStatus.values.map((e) => e.label),
        ...UserRole.values.map((e) => e.label),
      ];
      expect(labels.where((l) => l.isEmpty), isEmpty, reason: code);
    }
  });

  test('ApiException keeps the server text, else falls back in the active language', () {
    expect(const NotFoundApiException('Mahsulot topilmadi').message, 'Mahsulot topilmadi');
    setActiveLanguageCode('en');
    expect(const NetworkApiException().message, 'No internet connection.');
    setActiveLanguageCode('ru');
    expect(const ValidationApiException(null).message, 'Данные введены неверно.');
  });

  test('plural messages substitute the count (gen-l10n has no ICU `#`)', () {
    setActiveLanguageCode('ru');
    expect(appL10n.commonProductCount(1), '1 товар');
    expect(appL10n.commonProductCount(3), '3 товара');
    expect(appL10n.commonProductCount(5), '5 товаров');
    setActiveLanguageCode('en');
    expect(appL10n.ordersCartSummary(2, r'$4'), r'2 products — $4');
    setActiveLanguageCode('uz');
    expect(appL10n.commonProductCount(5), '5 ta mahsulot');
  });

  test('UZS amounts carry the localized suffix', () {
    setActiveLanguageCode('ru');
    expect(CurrencyFormatter.format(1500, Currency.uzs), endsWith(' сум'));
    setActiveLanguageCode('uz');
    expect(CurrencyFormatter.format(1500, Currency.uzs), endsWith(" so'm"));
    expect(CurrencyFormatter.format(12.5, Currency.usd), r'$12.5');
  });
}
