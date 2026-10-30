import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class UploadCrmDriverPhotoUseCase {
  UploadCrmDriverPhotoUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<CrmDriver>> call(String id, {required String filePath}) =>
      _repository.uploadDriverPhoto(id, filePath: filePath);
}
