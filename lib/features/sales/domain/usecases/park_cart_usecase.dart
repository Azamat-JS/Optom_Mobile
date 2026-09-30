import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart_write_params.dart';
import 'package:bsmart/features/sales/domain/repositories/shared_cart_repository.dart';

class ParkCartUseCase {
  ParkCartUseCase(this._repository);

  final SharedCartRepository _repository;

  Future<Result<SharedCart>> call(CreateSharedCartParams params) => _repository.park(params);
}
