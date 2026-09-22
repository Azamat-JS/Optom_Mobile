import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/repositories/orders_repository.dart';

class GetOrderUseCase {
  GetOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<Order>> call(String id) => _repository.getById(id);
}
