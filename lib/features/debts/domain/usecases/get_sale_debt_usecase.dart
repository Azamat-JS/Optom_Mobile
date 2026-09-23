import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/repositories/debts_repository.dart';

class GetSaleDebtUseCase {
  GetSaleDebtUseCase(this._repository);

  final DebtsRepository _repository;

  Future<Result<SaleDebt>> call(String id) => _repository.getSaleDebtById(id);
}
