import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_query.dart';
import 'package:bsmart/features/orders/domain/repositories/orders_repository.dart';

class ListOrdersUseCase {
  ListOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<PaginatedResult<Order>>> call(OrderQuery query) => _repository.list(query);
}
