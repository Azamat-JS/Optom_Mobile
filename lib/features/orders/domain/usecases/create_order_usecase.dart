import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';
import 'package:bsmart/features/orders/domain/repositories/orders_repository.dart';

class CreateOrderUseCase {
  CreateOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<Order>> call(CreateOrderParams params) => _repository.create(params);
}
