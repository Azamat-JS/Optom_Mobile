import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Marker bitmaps drawn in code (no image assets), cached per colour.
abstract final class MapIcons {
  static final _cache = <int, BitmapDescriptor>{};

  /// A circular courier badge with a direction arrow pointing up (north) — use with
  /// `Marker(flat: true, anchor: Offset(0.5, 0.5), rotation: bearing)` so it turns with travel.
  static Future<BitmapDescriptor> courier(Color color) async {
    final key = color.toARGB32();
    final cached = _cache[key];
    if (cached != null) return cached;

    const size = 96.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const center = Offset(size / 2, size / 2);
    canvas.drawCircle(center, size / 2, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawCircle(center, size * 0.32, Paint()..color = Colors.white);
    canvas.drawCircle(center, size * 0.27, Paint()..color = color);
    final arrow = Path()
      ..moveTo(size / 2, size * 0.30)
      ..lineTo(size * 0.63, size * 0.64)
      ..lineTo(size / 2, size * 0.56)
      ..lineTo(size * 0.37, size * 0.64)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.white);

    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final icon = BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), width: 40, height: 40);
    return _cache[key] = icon;
  }
}
