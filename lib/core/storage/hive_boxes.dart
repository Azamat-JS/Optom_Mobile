import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Registry of Hive box names, opened once in `bootstrap.dart`.
///
/// These boxes are a **read cache**, not an offline-write queue: repositories
/// write-through on a successful remote fetch and fall back to the cached
/// value on [NetworkApiException]. No box here ever holds unsynced mutations
/// (orders/sales/payments always require a live connection in Phase 1) — see
/// the offline-strategy section of the implementation plan for why.
abstract final class HiveBoxes {
  static const session = 'bsmart.session_cache';
  static const activeStore = 'bsmart.active_store';
  static const products = 'bsmart.products_cache';
  static const categories = 'bsmart.categories_cache';
  static const customers = 'bsmart.customers_cache';

  static Future<void> openAll() async {
    await Future.wait([
      Hive.openBox<dynamic>(session),
      Hive.openBox<dynamic>(activeStore),
      Hive.openBox<dynamic>(products),
      Hive.openBox<dynamic>(categories),
      Hive.openBox<dynamic>(customers),
    ]);
  }
}
