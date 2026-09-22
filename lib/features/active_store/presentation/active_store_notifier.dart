import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/storage/active_store_storage.dart';

/// The owner's selected branch. Invisible/unused for locked staff (their
/// store is fixed server-side via the JWT `storeId` claim) — see the
/// implementation plan's multi-store section. Full Store CRUD/switcher UI
/// lands in Milestone 6; this just holds the persisted selection so the
/// `ActiveStoreInterceptor` and any store-scoped screen can react to it.
///
/// Hand-written (not `@riverpod` code-gen — see `analysis_options.yaml`'s
/// note on why `riverpod_generator` is disabled for now).
class ActiveStoreNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() => getIt<ActiveStoreStorage>().read();

  Future<void> select(String storeId) async {
    await getIt<ActiveStoreStorage>().save(storeId);
    state = AsyncData(storeId);
  }

  Future<void> clear() async {
    await getIt<ActiveStoreStorage>().clear();
    state = const AsyncData(null);
  }
}

final activeStoreNotifierProvider = AsyncNotifierProvider<ActiveStoreNotifier, String?>(
  ActiveStoreNotifier.new,
);
