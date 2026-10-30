import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/crm/domain/entities/crm_visit.dart';
import 'package:bsmart/features/crm/domain/repositories/crm_repository.dart';

class UpdateCrmReminderUseCase {
  UpdateCrmReminderUseCase(this._repository);

  final CrmRepository _repository;

  Future<Result<void>> call(String id, {CrmItemStatus? status, DateTime? dueDate}) =>
      _repository.updateReminder(id, status: status, dueDate: dueDate);
}
