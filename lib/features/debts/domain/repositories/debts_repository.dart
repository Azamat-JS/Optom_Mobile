import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/entities/debt_query.dart';
import 'package:bsmart/features/debts/domain/entities/pay_down_result.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';

abstract class DebtsRepository {
  Future<Result<PaginatedResult<Debt>>> list(DebtQuery query);

  Future<Result<Debt>> getById(String id);

  Future<Result<Debt>> close(String id, CloseDebtParams params);

  Future<Result<PaginatedResult<SaleDebt>>> listSaleDebts(SaleDebtQuery query);

  Future<Result<SaleDebt>> getSaleDebtById(String id);

  Future<Result<void>> createPayment(CreatePaymentParams params);

  Future<Result<PayDownResult>> payDown(PayDownParams params);
}
