import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/customers/domain/repositories/customers_repository.dart';

class DeleteCustomerUseCase {
  DeleteCustomerUseCase(this._repository);

  final CustomersRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
