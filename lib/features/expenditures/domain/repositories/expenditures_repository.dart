import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_list_result.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_query.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure_write_params.dart';

abstract class ExpendituresRepository {
  Future<Result<ExpenditureListResult>> list(ExpenditureQuery query);

  Future<Result<Expenditure>> create(CreateExpenditureParams params);

  Future<Result<Expenditure>> update(String id, UpdateExpenditureParams params);

  Future<Result<void>> delete(String id);
}
