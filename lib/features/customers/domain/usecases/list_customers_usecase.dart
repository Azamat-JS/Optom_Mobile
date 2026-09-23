import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_query.dart';
import 'package:bsmart/features/customers/domain/repositories/customers_repository.dart';

class ListCustomersUseCase {
  ListCustomersUseCase(this._repository);

  final CustomersRepository _repository;

  Future<Result<PaginatedResult<Customer>>> call(CustomerQuery query) => _repository.list(query);
}
