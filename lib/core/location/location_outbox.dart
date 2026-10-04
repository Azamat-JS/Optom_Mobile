import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:bsmart/core/location/location_fix.dart';
import 'package:bsmart/core/storage/hive_boxes.dart';

/// Where [LocationOutbox] keeps its fixes — on disk in the app, in memory in tests.
abstract interface class OutboxStore {
  List<Map<String, dynamic>> load();
  void save(List<Map<String, dynamic>> fixes);
}

class HiveOutboxStore implements OutboxStore {
  static const _key = 'fixes';

  Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.locationOutbox);

  @override
  List<Map<String, dynamic>> load() {
    final raw = _box.get(_key);
    if (raw is! List) return [];
    return raw.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList();
  }

  @override
  void save(List<Map<String, dynamic>> fixes) => _box.put(_key, fixes);
}

class MemoryOutboxStore implements OutboxStore {
  List<Map<String, dynamic>> data = [];

  @override
  List<Map<String, dynamic>> load() => List.of(data);

  @override
  void save(List<Map<String, dynamic>> fixes) => data = List.of(fixes);
}

/// Phase 7 N5 — GPS fixes taken while the courier is online but the tracking socket isn't
/// (tunnel, lift, no signal), kept in order on disk so the route history has no gap. They're
/// sent oldest-first as `location:batch` once the session is back, before any new live point.
///
/// Bounded both ways: at most [maxFixes] (oldest dropped first) and nothing older than [maxAge]
/// — the server's backfill window is 30 min, anything older would be rejected anyway.
class LocationOutbox {
  LocationOutbox(this._store, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const maxFixes = 1000;
  static const maxAge = Duration(minutes: 29);

  /// Points per `location:batch` (server limit: 200).
  static const batchSize = 100;

  final OutboxStore _store;
  final DateTime Function() _clock;
  List<LocationFix>? _fixes;

  List<LocationFix> get _list => _fixes ??= _store.load().map(LocationFix.fromJson).toList();

  int get length {
    _prune();
    return _list.length;
  }

  bool get isEmpty => length == 0;
  bool get isNotEmpty => !isEmpty;

  /// Appends [fix] if it's newer than the last queued one (the server rejects anything older).
  void add(LocationFix fix) {
    final list = _list;
    if (list.isNotEmpty && !fix.timestamp.isAfter(list.last.timestamp)) return;
    list.add(fix);
    if (list.length > maxFixes) list.removeRange(0, list.length - maxFixes);
    _prune(persist: false);
    _persist();
  }

  /// The oldest [batchSize] fixes (not removed — call [removeFirst] once the server acked them).
  List<LocationFix> nextBatch() {
    _prune();
    final list = _list;
    return list.sublist(0, list.length < batchSize ? list.length : batchSize);
  }

  void removeFirst(int count) {
    final list = _list;
    list.removeRange(0, count.clamp(0, list.length));
    _persist();
  }

  void clear() {
    _list.clear();
    _persist();
  }

  void _prune({bool persist = true}) {
    final cutoff = _clock().subtract(maxAge);
    final list = _list;
    final stale = list.indexWhere((f) => !f.timestamp.isBefore(cutoff));
    final drop = stale == -1 ? list.length : stale;
    if (drop == 0) return;
    list.removeRange(0, drop);
    if (persist) _persist();
  }

  void _persist() => _store.save(_list.map((f) => f.toJson()).toList());
}
