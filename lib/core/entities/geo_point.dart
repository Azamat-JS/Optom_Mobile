/// A plain latitude/longitude pair for domain params (delivery drop-off pins,
/// store pickup points) — deliberately free of any map-SDK type.
class GeoPoint {
  const GeoPoint(this.lat, this.lng);

  final double lat;
  final double lng;

  String get label => '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}
