import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_query.dart';
import 'package:bsmart/features/storefront/domain/repositories/storefront_repository.dart';

class BrowseStorefrontUseCase {
  BrowseStorefrontUseCase(this._repository);

  final StorefrontRepository _repository;

  Future<Result<PaginatedResult<StorefrontProduct>>> call(StorefrontQuery query) => _repository.listProducts(query);
}
