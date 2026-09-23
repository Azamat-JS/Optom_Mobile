import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_write_params.dart';
import 'package:bsmart/features/expenditures/domain/repositories/expenditures_repository.dart';

class UpdateExpenditureUseCase {
  UpdateExpenditureUseCase(this._repository);

  final ExpendituresRepository _repository;

  Future<Result<Expenditure>> call(String id, UpdateExpenditureParams params) => _repository.update(id, params);
}
