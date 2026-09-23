import 'package:dio/dio.dart';

import 'package:bsmart/core/utils/decimal_parser.dart';
import 'package:bsmart/features/debts/domain/entities/pay_down_result.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';

/// Raw `/payments` calls — records a payment against a single `Debt`/
/// `SaleDebt`, or a FIFO lump-sum pay-down across all of one person's
/// outstanding debts (`POST /payments/pay-down`).
class PaymentsRemoteDataSource {
  PaymentsRemoteDataSource(this._dio);

  final Dio _dio;

  /// Returns the raw response — callers re-fetch the affected `Debt`/
  /// `SaleDebt` afterward rather than parsing this endpoint's two possible
  /// response shapes (`{payment, debt}` vs `{payment, saleDebt}`).
  Future<void> create(CreatePaymentParams params) => _dio.post<void>('/payments', data: params.toRequestBody());

  Future<PayDownResult> payDown(PayDownParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/payments/pay-down', data: params.toRequestBody());
    final data = response.data!;
    return PayDownResult(
      paymentCount: (data['payments'] as List<dynamic>? ?? const []).length,
      totalApplied: parseDecimal(data['totalApplied']),
      remainingBalance: parseDecimal(data['remainingBalance']),
    );
  }
}
