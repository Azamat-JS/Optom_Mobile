import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';

class UploadMasterProductImageUseCase {
  UploadMasterProductImageUseCase(this._repository);

  final MasterCatalogRepository _repository;

  Future<Result<MasterProductImageRef>> call(String id, {required String filePath, bool isPrimary = false}) =>
      _repository.uploadImage(id, filePath: filePath, isPrimary: isPrimary);
}
