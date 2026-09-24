import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product_write_params.dart';

abstract class MasterCatalogRepository {
  Future<Result<PaginatedResult<MasterProduct>>> search({
    String? search,
    String? categoryId,
    String? barcode,
    MasterProductStatus? status,
    int page,
    int limit,
  });

  Future<Result<MasterProduct>> getById(String id);

  Future<Result<MasterProduct>> create(CreateMasterProductParams params);

  Future<Result<MasterProduct>> update(String id, UpdateMasterProductParams params);

  Future<Result<MasterProduct>> approve(String id);

  Future<Result<MasterProduct>> reject(String id, {String? reason});

  Future<Result<void>> delete(String id);

  Future<Result<MasterProductImageRef>> uploadImage(String id, {required String filePath, bool isPrimary});

  Future<Result<void>> removeImage(String id, String imageId);
}
