import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_driver.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class GetCrmDriverTelegramUseCase {
  GetCrmDriverTelegramUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<CrmTelegramStatus>> call(String id) => _repository.getDriverTelegram(id);
}
