import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/maps/polyline_codec.dart';

void main() {
  test('decodes Google\'s reference polyline', () {
    // Example from Google's "Encoded Polyline Algorithm Format" documentation.
    final pts = decodePolyline('_p~iF~ps|U_ulLnnqC_mqNvxq`@');
    expect(pts, hasLength(3));
    expect(pts[0].latitude, closeTo(38.5, 1e-9));
    expect(pts[0].longitude, closeTo(-120.2, 1e-9));
    expect(pts[1].latitude, closeTo(40.7, 1e-9));
    expect(pts[1].longitude, closeTo(-120.95, 1e-9));
    expect(pts[2].latitude, closeTo(43.252, 1e-9));
    expect(pts[2].longitude, closeTo(-126.453, 1e-9));
  });

  test('empty input → no points', () => expect(decodePolyline(''), isEmpty));
}
