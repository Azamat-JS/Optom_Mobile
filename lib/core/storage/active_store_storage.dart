import 'package:shared_preferences/shared_preferences.dart';

/// Persists the owner's selected branch (not sensitive — plain
/// SharedPreferences, unlike [SecureTokenStorage]). Read directly by
/// [ActiveStoreInterceptor] (core/network) and wrapped by
/// `features/active_store`'s data layer for the domain/presentation sides —
/// core never depends on a feature, only the other way around.
class ActiveStoreStorage {
  static const _key = 'bsmart.active_store_id';

  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> save(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, storeId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
