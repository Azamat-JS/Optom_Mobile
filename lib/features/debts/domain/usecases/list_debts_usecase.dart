import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/entities/debt_query.dart';
import 'package:bsmart/features/debts/domain/repositories/debts_repository.dart';

class ListDebtsUseCase {
  ListDebtsUseCase(this._repository);

  final DebtsRepository _repository;

  Future<Result<PaginatedResult<Debt>>> call(DebtQuery query) => _repository.list(query);
}
