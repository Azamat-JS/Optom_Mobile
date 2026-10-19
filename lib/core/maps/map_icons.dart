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

  static final _pinCache = <String, BitmapDescriptor>{};

  /// Teardrop pin with [glyph] inside (the shop / destination pins). Its tip
  /// is the bottom centre: use `anchor: Offset(0.5, 1)`.
  static Future<BitmapDescriptor> pin(
    IconData glyph, {
    required Color fill,
    required Color ring,
    required Color glyphColor,
  }) async {
    final key = '${glyph.codePoint}-${fill.toARGB32()}-${ring.toARGB32()}-${glyphColor.toARGB32()}';
    final cached = _pinCache[key];
    if (cached != null) return cached;

    const w = 96.0;
    const h = 124.0;
    const r = w / 2 - 4;
    const center = Offset(w / 2, r + 4);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final body = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r))
      ..moveTo(w / 2 - 16, center.dy + r - 6)
      ..lineTo(w / 2, h - 4)
      ..lineTo(w / 2 + 16, center.dy + r - 6)
      ..close();
    canvas.drawShadow(body, Colors.black, 4, false);
    canvas.drawPath(body, Paint()..color = fill);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    final text = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(glyph.codePoint),
        style: TextStyle(fontFamily: glyph.fontFamily, package: glyph.fontPackage, fontSize: 48, color: glyphColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, center - Offset(text.width / 2, text.height / 2));

    final image = await recorder.endRecording().toImage(w.toInt(), h.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final icon = BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), width: 40, height: 52);
    return _pinCache[key] = icon;
  }
}
