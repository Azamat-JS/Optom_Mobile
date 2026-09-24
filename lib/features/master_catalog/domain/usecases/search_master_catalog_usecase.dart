import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';

class SearchMasterCatalogUseCase {
  SearchMasterCatalogUseCase(this._repository);

  final MasterCatalogRepository _repository;

  Future<Result<PaginatedResult<MasterProduct>>> call({
    String? search,
    String? categoryId,
    String? barcode,
    MasterProductStatus? status,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.search(
      search: search,
      categoryId: categoryId,
      barcode: barcode,
      status: status,
      page: page,
      limit: limit,
    );
  }
}
