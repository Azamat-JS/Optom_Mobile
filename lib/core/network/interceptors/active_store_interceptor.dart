import 'package:dio/dio.dart';

import 'package:bsmart/core/storage/active_store_storage.dart';

/// Attaches `X-Store-Id` for owner roles (SELLER/RETAILER) with an active
/// store selected. Locked staff (`_ADMIN`/WAITER/COURIER) never set an active
/// store client-side, so this header is simply absent for them — harmless,
/// since the backend's `JwtAuthGuard` only ever reads it for owner roles.
class ActiveStoreInterceptor extends Interceptor {
  ActiveStoreInterceptor(this._storage);

  final ActiveStoreStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storeId = await _storage.read();
    if (storeId != null) {
      options.headers['X-Store-Id'] = storeId;
    }
    handler.next(options);
  }
}
