import 'dart:math' as math;

/// One GPS fix as sent to the tracking socket (`location` event payload).
class LocationFix {
  const LocationFix({
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.accuracy,
    this.speed,
    this.heading,
  });

  final double lat;
  final double lng;
  final double? accuracy;

  /// Metres per second; null when the platform doesn't know.
  final double? speed;
  final double? heading;

  /// Device fix time.
  final DateTime timestamp;

  factory LocationFix.fromJson(Map<String, dynamic> json) => LocationFix(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        speed: (json['speed'] as num?)?.toDouble(),
        heading: (json['heading'] as num?)?.toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as num).toInt()),
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  double distanceTo(LocationFix other) {
    const r = 6371000.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(other.lat - lat);
    final dLng = rad(other.lng - lng);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat)) * math.cos(rad(other.lat)) * math.pow(math.sin(dLng / 2), 2);
    return 2 * r * math.asin(math.sqrt(h));
  }
}

/// Decides which GPS fixes are worth sending — the battery/data budget.
///
/// Moving: send when [movingInterval] has passed **or** the courier moved
/// [movingDistance]. Stationary: only every [stationaryInterval]. Never
/// faster than [minInterval] (the server rate-limits at 500 ms anyway).
abstract final class LocationSendPolicy {
  static const movingInterval = Duration(seconds: 3);
  static const movingDistance = 15.0;
  static const stationaryInterval = Duration(seconds: 20);
  static const minInterval = Duration(seconds: 1);
  static const movingSpeed = 1.0; // m/s — slower than this counts as stationary

  static bool shouldSend({required LocationFix? lastSent, required LocationFix fix}) {
    if (lastSent == null) return true;
    final elapsed = fix.timestamp.difference(lastSent.timestamp);
    if (elapsed < minInterval) return false;
    final moved = lastSent.distanceTo(fix);
    final isMoving = (fix.speed ?? 0) >= movingSpeed || moved >= movingDistance;
    if (!isMoving) return elapsed >= stationaryInterval;
    return elapsed >= movingInterval || moved >= movingDistance;
  }
}
