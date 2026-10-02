import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bsmart/core/maps/animated_position.dart';

void main() {
  test('lerpBearing turns the short way round', () {
    expect(lerpBearing(350, 10, 0.5), closeTo(0, 1e-9));
    expect(lerpBearing(10, 350, 0.5), closeTo(0, 1e-9));
    expect(lerpBearing(90, 180, 0.5), closeTo(135, 1e-9));
  });

  test('bearingBetween gives compass bearings', () {
    const a = LatLng(41.3, 69.2);
    expect(bearingBetween(a, const LatLng(41.4, 69.2)), closeTo(0, 0.5)); // north
    expect(bearingBetween(a, const LatLng(41.3, 69.3)), closeTo(90, 0.5)); // east
    expect(bearingBetween(a, const LatLng(41.2, 69.2)), closeTo(180, 0.5)); // south
  });

  testWidgets('AnimatedPosition glides to the target instead of teleporting', (tester) async {
    final anim = AnimatedPosition(vsync: tester, duration: const Duration(seconds: 1));
    anim.moveTo(const LatLng(41.0, 69.0));
    expect(anim.value!.position, const LatLng(41.0, 69.0)); // first point: placed directly

    anim.moveTo(const LatLng(42.0, 69.0));
    await tester.pump(); // first frame starts the ticker clock
    await tester.pump(const Duration(milliseconds: 500));
    final mid = anim.value!.position.latitude;
    expect(mid, greaterThan(41.0));
    expect(mid, lessThan(42.0));
    await tester.pump(const Duration(seconds: 1));
    expect(anim.value!.position.latitude, closeTo(42.0, 1e-9));
    expect(anim.value!.bearing, closeTo(0, 0.5)); // moved north
    anim.dispose();
  });
}
