import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_write_params.dart';
import 'package:bsmart/features/expenditures/domain/repositories/expenditures_repository.dart';

class CreateExpenditureUseCase {
  CreateExpenditureUseCase(this._repository);

  final ExpendituresRepository _repository;

  Future<Result<Expenditure>> call(CreateExpenditureParams params) => _repository.create(params);
}
