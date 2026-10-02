import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A position + bearing that glides between updates instead of teleporting.
///
/// Each [moveTo] animates linearly from wherever the marker currently *is*
/// (even mid-animation) to the new point over [duration], and rotates the
/// heading the short way round (350° → 10° turns 20°, not 340°). Bearing comes
/// from the device heading when it's moving, otherwise from the direction of
/// travel, otherwise it's kept. Shared by every live map (courier, customer,
/// fleet).
class AnimatedPosition extends ValueNotifier<({LatLng position, double bearing})?> {
  AnimatedPosition({required TickerProvider vsync, this.duration = const Duration(milliseconds: 1500)})
      : _controller = AnimationController(vsync: vsync, duration: duration),
        super(null) {
    _controller.addListener(_tick);
  }

  final Duration duration;
  final AnimationController _controller;

  LatLng? _from;
  LatLng? _to;
  double _fromBearing = 0;
  double _toBearing = 0;

  void moveTo(LatLng target, {double? heading}) {
    final current = value;
    if (current == null) {
      value = (position: target, bearing: heading ?? 0);
      return;
    }
    _from = current.position;
    _to = target;
    _fromBearing = current.bearing;
    _toBearing = heading ?? (_meters(_from!, target) > 3 ? bearingBetween(_from!, target) : current.bearing);
    _controller
      ..stop()
      ..forward(from: 0);
  }

  void _tick() {
    final from = _from, to = _to;
    if (from == null || to == null) return;
    final t = Curves.easeInOut.transform(_controller.value);
    value = (
      position: LatLng(from.latitude + (to.latitude - from.latitude) * t, from.longitude + (to.longitude - from.longitude) * t),
      bearing: lerpBearing(_fromBearing, _toBearing, t),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double _meters(LatLng a, LatLng b) {
    const r = 6371000.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(b.latitude - a.latitude);
    final dLng = rad(b.longitude - a.longitude);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(a.latitude)) * math.cos(rad(b.latitude)) * math.pow(math.sin(dLng / 2), 2);
    return 2 * r * math.asin(math.sqrt(h));
  }
}

/// Compass bearing (0–360, 0 = north) from [a] to [b].
double bearingBetween(LatLng a, LatLng b) {
  double rad(double d) => d * math.pi / 180;
  final dLng = rad(b.longitude - a.longitude);
  final y = math.sin(dLng) * math.cos(rad(b.latitude));
  final x = math.cos(rad(a.latitude)) * math.sin(rad(b.latitude)) -
      math.sin(rad(a.latitude)) * math.cos(rad(b.latitude)) * math.cos(dLng);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// Interpolates two compass bearings the short way round.
double lerpBearing(double from, double to, double t) {
  final delta = ((to - from + 540) % 360) - 180;
  return (from + delta * t + 360) % 360;
}
