import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class DeleteProductImageUseCase {
  DeleteProductImageUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<void>> call(String productId, String imageId) => _repository.deleteImage(productId, imageId);
}
