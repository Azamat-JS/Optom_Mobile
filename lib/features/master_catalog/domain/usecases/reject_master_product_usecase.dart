import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/repositories/master_catalog_repository.dart';

class RejectMasterProductUseCase {
  RejectMasterProductUseCase(this._repository);

  final MasterCatalogRepository _repository;

  Future<Result<MasterProduct>> call(String id, {String? reason}) => _repository.reject(id, reason: reason);
}
