import 'package:flutter/material.dart';

/// A single seed-based Material 3 theme for Phase 1. Per-role theming
/// (if ever wanted) is a later concern — not needed until multiple roles
/// exist side by side.
abstract final class AppTheme {
  static const _seed = Color(0xFF1D6E4F); // deep green — trade/commerce, distinct from the reference web app's neutral shadcn palette

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
