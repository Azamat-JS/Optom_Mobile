import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/orders/domain/entities/order_write_params.dart';
import 'package:bsmart/features/orders/domain/repositories/orders_repository.dart';

class UpdateOrderStatusUseCase {
  UpdateOrderStatusUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Result<Order>> call(String id, UpdateOrderStatusParams params) => _repository.updateStatus(id, params);
}
