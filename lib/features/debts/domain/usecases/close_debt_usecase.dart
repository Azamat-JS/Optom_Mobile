import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';
import 'package:bsmart/features/debts/domain/repositories/debts_repository.dart';

class CloseDebtUseCase {
  CloseDebtUseCase(this._repository);

  final DebtsRepository _repository;

  Future<Result<Debt>> call(String id, CloseDebtParams params) => _repository.close(id, params);
}
