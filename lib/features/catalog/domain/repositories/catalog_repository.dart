import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_product.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_query.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';

abstract class CatalogRepository {
  Future<Result<List<CatalogSeller>>> listSellers();

  Future<Result<List<CatalogStore>>> listStoresForSeller(String sellerId);

  Future<Result<PaginatedResult<CatalogProduct>>> listProducts(CatalogQuery query);
}
