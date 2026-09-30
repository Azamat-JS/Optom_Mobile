import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/location/location_fix.dart';

void main() {
  final t0 = DateTime(2026, 9, 30, 12);
  // ~0.0001° latitude ≈ 11 m.
  LocationFix fix(double dLat, Duration after, {double? speed}) => LocationFix(
        lat: 41.3111 + dLat,
        lng: 69.2797,
        timestamp: t0.add(after),
        speed: speed,
      );
  final base = fix(0, Duration.zero, speed: 0);

  test('first fix is always sent', () {
    expect(LocationSendPolicy.shouldSend(lastSent: null, fix: base), isTrue);
  });

  test('never faster than 1 s, even after a big move', () {
    expect(LocationSendPolicy.shouldSend(lastSent: base, fix: fix(0.001, const Duration(milliseconds: 500))), isFalse);
  });

  test('moving: sends after 3 s', () {
    expect(LocationSendPolicy.shouldSend(lastSent: base, fix: fix(0.00005, const Duration(seconds: 2), speed: 5)), isFalse);
    expect(LocationSendPolicy.shouldSend(lastSent: base, fix: fix(0.00005, const Duration(seconds: 3), speed: 5)), isTrue);
  });

  test('moving: sends early once 15 m covered', () {
    expect(LocationSendPolicy.shouldSend(lastSent: base, fix: fix(0.0002, const Duration(seconds: 1, milliseconds: 500))), isTrue);
  });

  test('stationary: only every 20 s', () {
    expect(LocationSendPolicy.shouldSend(lastSent: base, fix: fix(0.00001, const Duration(seconds: 10), speed: 0)), isFalse);
    expect(LocationSendPolicy.shouldSend(lastSent: base, fix: fix(0.00001, const Duration(seconds: 20), speed: 0)), isTrue);
  });
}
