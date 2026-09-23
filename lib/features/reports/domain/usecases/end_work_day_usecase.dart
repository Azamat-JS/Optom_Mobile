import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/reports/domain/entities/work_day.dart';
import 'package:bsmart/features/reports/domain/repositories/reports_repository.dart';

class EndWorkDayUseCase {
  EndWorkDayUseCase(this._repository);

  final ReportsRepository _repository;

  Future<Result<WorkDay>> call() => _repository.endWorkDay();
}
