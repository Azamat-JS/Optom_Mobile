import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/features/sales/domain/repositories/sales_repository.dart';

class CreateSaleUseCase {
  CreateSaleUseCase(this._repository);

  final SalesRepository _repository;

  Future<Result<Sale>> call(CreateSaleParams params) => _repository.create(params);
}
