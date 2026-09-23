import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_query.dart';

abstract class StorefrontRepository {
  Future<Result<List<StorefrontCategory>>> listCategories();

  Future<Result<PaginatedResult<StorefrontProduct>>> listProducts(StorefrontQuery query);

  Future<Result<StorefrontProduct>> getProduct(String id);
}
