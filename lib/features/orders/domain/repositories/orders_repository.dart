import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_query.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';

abstract class OrdersRepository {
  Future<Result<PaginatedResult<Order>>> list(OrderQuery query);

  Future<Result<Order>> getById(String id);

  Future<Result<Order>> create(CreateOrderParams params);

  Future<Result<Order>> updateStatus(String id, UpdateOrderStatusParams params);
}
