import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/repositories/debts_repository.dart';

class GetDebtUseCase {
  GetDebtUseCase(this._repository);

  final DebtsRepository _repository;

  Future<Result<Debt>> call(String id) => _repository.getById(id);
}
