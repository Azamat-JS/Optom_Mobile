import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_write_params.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class ReceiveStockUseCase {
  ReceiveStockUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<Product>> call(String id, ReceiveStockParams params) => _repository.receiveStock(id, params);
}
