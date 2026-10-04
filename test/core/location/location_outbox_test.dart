import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/location/location_fix.dart';
import 'package:bsmart/core/location/location_outbox.dart';

// Phase 7 N5: the offline GPS backlog.
void main() {
  final t0 = DateTime(2026, 10, 4, 12);
  late DateTime now;
  late MemoryOutboxStore store;
  LocationOutbox outbox() => LocationOutbox(store, clock: () => now);
  LocationFix fix(int sec, {double lat = 41.3}) =>
      LocationFix(lat: lat, lng: 69.2, accuracy: 5, timestamp: t0.add(Duration(seconds: sec)));

  setUp(() {
    now = t0.add(const Duration(minutes: 1));
    store = MemoryOutboxStore();
  });

  test('keeps fixes in order and ignores one that is not newer', () {
    final o = outbox()
      ..add(fix(1))
      ..add(fix(5))
      ..add(fix(5)) // same time
      ..add(fix(3)); // older
    expect(o.nextBatch().map((f) => f.timestamp), [fix(1).timestamp, fix(5).timestamp]);
  });

  test('survives a restart (persisted through the store)', () {
    outbox()
      ..add(fix(1, lat: 41.1))
      ..add(fix(2, lat: 41.2));
    final reopened = outbox();
    expect(reopened.length, 2);
    expect(reopened.nextBatch().last.lat, 41.2);
  });

  test('is bounded: the oldest are dropped beyond maxFixes', () {
    now = t0.add(const Duration(hours: 1));
    final o = outbox();
    final start = 3600 - LocationOutbox.maxFixes - 9; // all within maxAge of `now`
    for (var i = 0; i < LocationOutbox.maxFixes + 10; i++) {
      o.add(fix(start + i));
    }
    expect(o.length, LocationOutbox.maxFixes);
    expect(o.nextBatch().first.timestamp, fix(start + 10).timestamp);
  });

  test('drops fixes older than maxAge (the server would reject them)', () {
    final o = outbox()
      ..add(fix(0))
      ..add(fix(600));
    now = t0.add(LocationOutbox.maxAge).add(const Duration(minutes: 1));
    expect(o.length, 1);
    expect(o.nextBatch().single.timestamp, fix(600).timestamp);
  });

  test('batches of batchSize, removed only once acked', () {
    final o = outbox();
    for (var i = 0; i < 150; i++) {
      o.add(fix(i));
    }
    final first = o.nextBatch();
    expect(first.length, LocationOutbox.batchSize);
    expect(o.length, 150); // not removed yet
    o.removeFirst(first.length);
    expect(o.length, 50);
    expect(o.nextBatch().first.timestamp, fix(100).timestamp);
  });

  test('clear empties it on disk too', () {
    outbox()
      ..add(fix(1))
      ..clear();
    expect(outbox().isEmpty, isTrue);
  });

  test('LocationFix JSON round-trips', () {
    final f = LocationFix(lat: 41.3, lng: 69.2, accuracy: 4, speed: 3.5, heading: 90, timestamp: t0);
    final back = LocationFix.fromJson(f.toJson());
    expect(back.toJson(), f.toJson());
  });
}
