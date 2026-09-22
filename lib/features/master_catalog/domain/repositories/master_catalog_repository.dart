import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';

abstract class MasterCatalogRepository {
  Future<Result<PaginatedResult<MasterProduct>>> search({
    String? search,
    String? categoryId,
    String? barcode,
    int page,
    int limit,
  });

  Future<Result<MasterProduct>> getById(String id);
}
