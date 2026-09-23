import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/debts/domain/entities/pay_down_result.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';
import 'package:bsmart/features/debts/domain/repositories/debts_repository.dart';

class PayDownUseCase {
  PayDownUseCase(this._repository);

  final DebtsRepository _repository;

  Future<Result<PayDownResult>> call(PayDownParams params) => _repository.payDown(params);
}
