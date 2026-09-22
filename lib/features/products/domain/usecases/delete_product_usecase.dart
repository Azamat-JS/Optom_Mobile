import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class DeleteProductUseCase {
  DeleteProductUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
