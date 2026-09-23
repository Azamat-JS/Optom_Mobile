import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class GetBestSellingProductsUseCase {
  GetBestSellingProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<List<Product>>> call({int limit = 18}) => _repository.bestSelling(limit: limit);
}
