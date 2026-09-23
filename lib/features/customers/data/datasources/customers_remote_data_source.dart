import 'package:dio/dio.dart';

import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/features/customers/data/models/customer_model.dart';
import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/domain/entities/customer_query.dart';
import 'package:bsmart/features/customers/domain/entities/customer_write_params.dart';

/// Raw `/customers` calls — a SELLER's or RETAILER's own B2C customer roster.
class CustomersRemoteDataSource {
  CustomersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PaginatedResult<Customer>> list(CustomerQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers',
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedResult.fromJson(response.data!, customerFromJson);
  }

  Future<Customer> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/customers/$id');
    return customerFromJson(response.data!);
  }

  Future<Customer> create(CreateCustomerParams params) async {
    final response = await _dio.post<Map<String, dynamic>>('/customers', data: params.toRequestBody());
    return customerFromJson(response.data!);
  }

  Future<Customer> update(String id, UpdateCustomerParams params) async {
    final response = await _dio.patch<Map<String, dynamic>>('/customers/$id', data: params.toRequestBody());
    return customerFromJson(response.data!);
  }

  Future<Customer> deactivate(String id) async {
    final response = await _dio.patch<Map<String, dynamic>>('/customers/$id/deactivate');
    return customerFromJson(response.data!);
  }

  Future<void> delete(String id) => _dio.delete<void>('/customers/$id');
}
