import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/expenditures/domain/repositories/expenditures_repository.dart';

class DeleteExpenditureUseCase {
  DeleteExpenditureUseCase(this._repository);

  final ExpendituresRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
