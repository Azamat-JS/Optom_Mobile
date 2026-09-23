import 'dart:typed_data';

import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/reports/domain/repositories/reports_repository.dart';

class ExportDebtsXlsxUseCase {
  ExportDebtsXlsxUseCase(this._repository);

  final ReportsRepository _repository;

  Future<Result<Uint8List>> call() => _repository.exportDebtsXlsx();
}
