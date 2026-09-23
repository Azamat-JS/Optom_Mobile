import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/repositories/stores_repository.dart';

class ListStoresUseCase {
  ListStoresUseCase(this._repository);

  final StoresRepository _repository;

  Future<Result<List<Store>>> call() => _repository.list();
}
