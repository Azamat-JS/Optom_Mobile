import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/repositories/customers_repository.dart';

/// `POST /customers/walk-in` — the store's anonymous buyer, for a sale nobody gave a name for.
class ResolveWalkInCustomerUseCase {
  ResolveWalkInCustomerUseCase(this._repository);

  final CustomersRepository _repository;

  Future<Result<Customer>> call() => _repository.resolveWalkIn();
}
