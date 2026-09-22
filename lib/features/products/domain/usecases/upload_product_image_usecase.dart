import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/entities/product_image.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class UploadProductImageUseCase {
  UploadProductImageUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<ProductImage>> call(String productId, {required String filePath, bool isPrimary = false}) {
    return _repository.uploadImage(productId, filePath: filePath, isPrimary: isPrimary);
  }
}
