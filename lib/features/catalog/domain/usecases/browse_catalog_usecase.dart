import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_product.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_query.dart';
import 'package:bsmart/features/catalog/domain/repositories/catalog_repository.dart';

class BrowseCatalogUseCase {
  BrowseCatalogUseCase(this._repository);

  final CatalogRepository _repository;

  Future<Result<PaginatedResult<CatalogProduct>>> call(CatalogQuery query) => _repository.listProducts(query);
}
