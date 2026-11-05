import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/repositories/sales_repository.dart';

class CreateManualRevenueUseCase {
  CreateManualRevenueUseCase(this._repository);

  final SalesRepository _repository;

  Future<Result<Sale>> call(CreateManualRevenueParams params) => _repository.createManualRevenue(params);
}
