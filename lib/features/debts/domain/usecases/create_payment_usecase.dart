import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/debts/domain/entities/payment_write_params.dart';
import 'package:bsmart/features/debts/domain/repositories/debts_repository.dart';

class CreatePaymentUseCase {
  CreatePaymentUseCase(this._repository);

  final DebtsRepository _repository;

  Future<Result<void>> call(CreatePaymentParams params) => _repository.createPayment(params);
}
