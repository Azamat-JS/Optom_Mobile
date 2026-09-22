import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class AssignBarcodeUseCase {
  AssignBarcodeUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<Product>> call(String id) => _repository.assignBarcode(id);
}
