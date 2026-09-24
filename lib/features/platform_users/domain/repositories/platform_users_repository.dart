import 'package:bsmart/core/network/paginated_result.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_query.dart';
import 'package:bsmart/features/platform_users/domain/entities/platform_user_write_params.dart';

abstract class PlatformUsersRepository {
  Future<Result<PaginatedResult<PlatformUser>>> list(PlatformUserQuery query);

  Future<Result<PlatformUser>> create(CreatePlatformUserParams params);

  Future<Result<PlatformUser>> update(String id, UpdatePlatformUserParams params);

  Future<Result<PlatformUser>> setActive(String id, bool isActive);

  Future<Result<void>> delete(String id);
}
