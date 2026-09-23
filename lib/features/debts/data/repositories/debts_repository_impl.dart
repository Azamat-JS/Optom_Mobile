import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/debts/data/datasources/debts_remote_data_source.dart';
import 'package:bsmart/features/debts/data/datasources/payments_remote_data_source.dart';
import 'package:bsmart/features/debts/data/datasources/sale_debts_remote_data_source.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/entities/debt_query.dart';
import 'package:bsmart/features/debts/domain/entities/pay_down_result.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';
import 'package:bsmart/features/debts/domain/repositories/debts_repository.dart';

class DebtsRepositoryImpl implements DebtsRepository {
  DebtsRepositoryImpl(this._debts, this._saleDebts, this._payments);

  final DebtsRemoteDataSource _debts;
  final SaleDebtsRemoteDataSource _saleDebts;
  final PaymentsRemoteDataSource _payments;

  @override
  Future<Result<PaginatedResult<Debt>>> list(DebtQuery query) async {
    try {
      return Result.ok(await _debts.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Debt>> getById(String id) async {
    try {
      return Result.ok(await _debts.getById(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Debt>> close(String id, CloseDebtParams params) async {
    try {
      return Result.ok(await _debts.close(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PaginatedResult<SaleDebt>>> listSaleDebts(SaleDebtQuery query) async {
    try {
      return Result.ok(await _saleDebts.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<SaleDebt>> getSaleDebtById(String id) async {
    try {
      return Result.ok(await _saleDebts.getById(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> createPayment(CreatePaymentParams params) async {
    try {
      await _payments.create(params);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<PayDownResult>> payDown(PayDownParams params) async {
    try {
      return Result.ok(await _payments.payDown(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
