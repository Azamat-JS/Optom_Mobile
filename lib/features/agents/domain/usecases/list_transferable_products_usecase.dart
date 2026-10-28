import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/agents/domain/entities/owner_agent.dart';
import 'package:bsmart/features/agents/domain/repositories/owner_agent_repository.dart';

class ListTransferableProductsUseCase {
  ListTransferableProductsUseCase(this._repository);

  final OwnerAgentRepository _repository;

  Future<Result<PaginatedResult<TransferableProduct>>> call(String leadId, {String? search}) =>
      _repository.transferableProducts(leadId, search: search);
}
