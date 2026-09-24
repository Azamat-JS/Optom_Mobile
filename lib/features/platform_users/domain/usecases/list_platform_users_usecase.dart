import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_query.dart';
import 'package:bsmart/features/platform_users/domain/repositories/platform_users_repository.dart';

class ListPlatformUsersUseCase {
  ListPlatformUsersUseCase(this._repository);

  final PlatformUsersRepository _repository;

  Future<Result<PaginatedResult<PlatformUser>>> call(PlatformUserQuery query) => _repository.list(query);
}
