import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/features/sales/data/models/sale_model.dart';
import 'package:bsmart/features/sales/domain/entities/sale_query.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/manual_revenue.dart';
import 'package:bsmart/core/entities/reporting_shared.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/payment_method.dart';

void main() {
  group('tashkentToday', () {
    test('is already the next day in Tashkent late in the UTC evening', () {
      expect(tashkentToday(DateTime.utc(2026, 11, 4, 19, 30)), DateTime(2026, 11, 5));
      expect(tashkentToday(DateTime.utc(2026, 11, 4, 18, 59)), DateTime(2026, 11, 4));
    });

    test('first pickable day is 366 days back', () {
      expect(manualRevenueFirstDate(DateTime.utc(2026, 11, 5, 5)), DateTime(2025, 11, 4));
    });
  });

  group('manualRevenueDateParam', () {
    final now = DateTime.utc(2026, 11, 5, 5); // 10:00 in Tashkent
    test('no day or today → nothing (booked now)', () {
      expect(manualRevenueDateParam(null, now), isNull);
      expect(manualRevenueDateParam(DateTime(2026, 11, 5), now), isNull);
      expect(manualRevenueDateParam(DateTime(2026, 11, 5, 18, 30), now), isNull);
    });
    test('a past day → YYYY-MM-DD', () {
      expect(manualRevenueDateParam(DateTime(2026, 11, 2), now), '2026-11-02');
      expect(manualRevenueDateParam(DateTime(2025, 1, 9), now), '2025-01-09');
    });
  });

  group('parseManualRevenueAmount', () {
    test('accepts grouped and comma-decimal amounts', () {
      expect(parseManualRevenueAmount('1 250 000'), 1250000);
      expect(parseManualRevenueAmount('120,5'), 120.5);
      expect(parseManualRevenueAmount(' 99.99 '), 99.99);
    });
    test('refuses empty, zero, negative, text and 3 decimals', () {
      for (final bad in ['', '0', '0.00', '-5', 'abc', '10.123', '1.2.3']) {
        expect(parseManualRevenueAmount(bad), isNull, reason: bad);
      }
    });
  });

  test('phone rule', () {
    expect(isValidManualRevenuePhone('+998 (93) 123-45-67'), isTrue);
    expect(isValidManualRevenuePhone('931234567'), isTrue);
    expect(isValidManualRevenuePhone('+998'), isFalse);
    expect(isValidManualRevenuePhone('12ab5678901'), isFalse);
  });

  group('params and models', () {
    test('request body: only what was filled in', () {
      expect(
        const CreateManualRevenueParams(amount: 5000, currency: Currency.uzs, paymentMethod: PaymentMethod.cash)
            .toRequestBody(),
        {'amount': 5000.0, 'currency': 'UZS', 'paymentMethod': 'CASH'},
      );
      expect(
        const CreateManualRevenueParams(
          amount: 25,
          currency: Currency.usd,
          paymentMethod: PaymentMethod.click,
          date: '2026-11-02',
          customer: ManualRevenueCustomer(firstName: 'Ali', phone: '+998901112233'),
        ).toRequestBody(),
        {
          'amount': 25.0,
          'currency': 'USD',
          'paymentMethod': 'CLICK',
          'date': '2026-11-02',
          'customer': {'firstName': 'Ali', 'phone': '+998901112233'},
        },
      );
      expect(
        const CreateManualRevenueParams(
          amount: 1,
          currency: Currency.uzs,
          paymentMethod: PaymentMethod.card,
          customerId: 'c1',
        ).toRequestBody()['customerId'],
        'c1',
      );
    });

    test('sale query sends kind', () {
      expect(const SaleQuery(kind: SaleKind.manual).toQueryParameters()['kind'], 'manual');
      expect(const SaleQuery().toQueryParameters().containsKey('kind'), isFalse);
      expect(const SaleQuery(kind: SaleKind.manual).copyWith(page: 2).kind, SaleKind.manual);
    });

    test('sale parses isManualRevenue (defaults to false) and refuses returns for it', () {
      Map<String, dynamic> json(bool? manual) => {
            'id': 's1',
            'saleNumber': 'SALE-1',
            'type': 'PAID',
            'status': 'COMPLETED',
            'currency': 'UZS',
            'subtotal': '5000',
            'discount': '0',
            'total': '5000',
            'createdAt': '2026-11-05T07:00:00.000Z',
            'isManualRevenue': ?manual,
          };
      final manual = saleFromJson(json(true));
      expect(manual.isManualRevenue, isTrue);
      expect(manual.canReturn, isFalse);
      expect(manual.canCancel, isTrue);
      final old = saleFromJson(json(null));
      expect(old.isManualRevenue, isFalse);
      expect(old.canReturn, isTrue);
      expect(old.canCancel, isFalse);
    });

    test('dashboard manual revenue block is optional', () {
      final stats = ManualRevenueStats.tryParse({
        'today': {
          'uzs': {'count': 2, 'amount': 15000},
          'usd': {'count': 0, 'amount': 0},
        },
        'last30': {
          'uzs': {'count': 3, 'amount': 20000},
          'usd': {'count': 1, 'amount': 12.5},
        },
        'allTime': {
          'uzs': {'count': 3, 'amount': 20000},
          'usd': {'count': 1, 'amount': 12.5},
        },
      });
      expect(stats!.today.uzs.amount, 15000);
      expect(stats.last30.usd.count, 1);
      expect(ManualRevenueStats.tryParse(null), isNull);
    });
  });
}
