import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/repositories/customers_repository.dart';

class GetCustomerUseCase {
  GetCustomerUseCase(this._repository);

  final CustomersRepository _repository;

  Future<Result<Customer>> call(String id) => _repository.getById(id);
}
