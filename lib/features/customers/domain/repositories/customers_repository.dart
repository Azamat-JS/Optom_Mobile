import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_query.dart';
import 'package:bsmart/features/customers/domain/entities/customer_write_params.dart';

abstract class CustomersRepository {
  Future<Result<PaginatedResult<Customer>>> list(CustomerQuery query);

  Future<Result<Customer>> getById(String id);

  Future<Result<Customer>> create(CreateCustomerParams params);

  Future<Result<Customer>> update(String id, UpdateCustomerParams params);

  Future<Result<Customer>> deactivate(String id);

  Future<Result<void>> delete(String id);
}
