import 'package:dio/dio.dart';

import 'package:bsmart/core/network/dio_error_mapper.dart';
import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/customers/data/datasources/customers_remote_data_source.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_query.dart';
import 'package:bsmart/features/customers/domain/entities/customer_write_params.dart';
import 'package:bsmart/features/customers/domain/repositories/customers_repository.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl(this._remote);

  final CustomersRemoteDataSource _remote;

  @override
  Future<Result<PaginatedResult<Customer>>> list(CustomerQuery query) async {
    try {
      return Result.ok(await _remote.list(query));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Customer>> getById(String id) async {
    try {
      return Result.ok(await _remote.getById(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Customer>> create(CreateCustomerParams params) async {
    try {
      return Result.ok(await _remote.create(params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Customer>> update(String id, UpdateCustomerParams params) async {
    try {
      return Result.ok(await _remote.update(id, params));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<Customer>> deactivate(String id) async {
    try {
      return Result.ok(await _remote.deactivate(id));
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _remote.delete(id);
      return const Result.ok(null);
    } on DioException catch (e) {
      return Result.err(mapDioException(e));
    }
  }
}
