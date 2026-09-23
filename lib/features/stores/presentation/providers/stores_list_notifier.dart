import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/features/stores/domain/usecases/list_stores_usecase.dart';

/// The owner's full store roster — no pagination, matching `GET /stores`'s
/// own small-working-set design. Powers both `StoresListScreen` and
/// `StoreSwitcher` (which reads this same provider rather than duplicating
/// the fetch).
class StoresListNotifier extends AsyncNotifier<List<Store>> {
  @override
  Future<List<Store>> build() => _fetch();

  Future<List<Store>> _fetch() async {
    final result = await getIt<ListStoresUseCase>().call();
    return result.fold((stores) => stores, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final storesListProvider = AsyncNotifierProvider<StoresListNotifier, List<Store>>(StoresListNotifier.new);
