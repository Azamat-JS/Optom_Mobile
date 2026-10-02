import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';

class ListDeliveriesUseCase {
  ListDeliveriesUseCase(this._repository);

  final DeliveriesRepository _repository;

  Future<Result<List<Delivery>>> call({bool openOnly = false}) => _repository.list(openOnly: openOnly);
}
