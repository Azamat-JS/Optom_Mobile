import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_list_result.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_query.dart';
import 'package:bsmart/features/expenditures/domain/repositories/expenditures_repository.dart';

class ListExpendituresUseCase {
  ListExpendituresUseCase(this._repository);

  final ExpendituresRepository _repository;

  Future<Result<ExpenditureListResult>> call(ExpenditureQuery query) => _repository.list(query);
}
