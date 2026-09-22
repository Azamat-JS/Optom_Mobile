import 'package:flutter/animation.dart';

/// Centralized animation timing so the whole app feels like one consistent
/// system rather than ad hoc per-screen durations — see the implementation
/// plan's "Animations — first-class, not decorative" section.
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 450);

  static const emphasized = Curves.easeOutCubic;
  static const standardCurve = Curves.easeInOut;
}
