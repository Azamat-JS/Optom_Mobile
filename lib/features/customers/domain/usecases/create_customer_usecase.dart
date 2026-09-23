import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_write_params.dart';
import 'package:bsmart/features/customers/domain/repositories/customers_repository.dart';

class CreateCustomerUseCase {
  CreateCustomerUseCase(this._repository);

  final CustomersRepository _repository;

  Future<Result<Customer>> call(CreateCustomerParams params) => _repository.create(params);
}
