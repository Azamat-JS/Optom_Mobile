import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin.dart';
import 'package:bsmart/features/staff_admins/domain/entities/admin_query.dart';
import 'package:bsmart/features/staff_admins/domain/usecases/list_admins_usecase.dart';

class AdminsListNotifier extends AsyncNotifier<List<Admin>> {
  @override
  Future<List<Admin>> build() => _fetch();

  Future<List<Admin>> _fetch() async {
    final result = await getIt<ListAdminsUseCase>().call(const AdminQuery());
    return result.fold((page) => page.data, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final adminsListProvider = AsyncNotifierProvider<AdminsListNotifier, List<Admin>>(AdminsListNotifier.new);
