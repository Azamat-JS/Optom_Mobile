import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';

class ApproveMasterProductUseCase {
  ApproveMasterProductUseCase(this._repository);

  final MasterCatalogRepository _repository;

  Future<Result<MasterProduct>> call(String id) => _repository.approve(id);
}
