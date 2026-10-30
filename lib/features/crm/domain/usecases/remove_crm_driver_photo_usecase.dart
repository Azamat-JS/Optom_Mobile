import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class RemoveCrmDriverPhotoUseCase {
  RemoveCrmDriverPhotoUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<CrmDriver>> call(String id) => _repository.removeDriverPhoto(id);
}
