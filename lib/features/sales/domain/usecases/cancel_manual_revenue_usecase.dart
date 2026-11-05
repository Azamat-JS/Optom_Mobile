import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/repositories/sales_repository.dart';

class CancelManualRevenueUseCase {
  CancelManualRevenueUseCase(this._repository);

  final SalesRepository _repository;

  Future<Result<Sale>> call(String saleId) => _repository.cancelManualRevenue(saleId);
}
