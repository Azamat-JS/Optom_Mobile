import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';
import 'package:bsmart/features/sales/domain/repositories/shared_cart_repository.dart';

class ListSharedCartsUseCase {
  ListSharedCartsUseCase(this._repository);

  final SharedCartRepository _repository;

  Future<Result<List<SharedCart>>> call() => _repository.list();
}
