import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/products/domain/entities/product_query.dart';
import 'package:bsmart/features/products/domain/repositories/products_repository.dart';

class ListProductsUseCase {
  ListProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<PaginatedResult<Product>>> call(ProductQuery query) => _repository.list(query);
}
