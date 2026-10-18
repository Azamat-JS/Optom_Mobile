import 'package:flutter/material.dart';

/// bsmart brand palette, taken from the logo (yellow + white on near-black).
///
/// Yellow is a fill colour only (buttons, badges, the active OTP-style box);
/// it fails contrast as text on white, so text that should read as "brand"
/// uses [goldInk] instead.
abstract final class AppColors {
  /// Logo yellow — primary button fill, focus accents on dark surfaces.
  static const brandYellow = Color(0xFFFFC904);

  /// Deeper logo yellow — focused input borders, pressed states.
  static const brandAmber = Color(0xFFF5B000);

  /// Brand-coloured text on light surfaces (5.7:1 on white).
  static const goldInk = Color(0xFF8A5D00);

  /// Text/icons placed on [brandYellow].
  static const onBrand = Color(0xFF14110A);

  /// Hero / splash background — matches the logo artwork's black.
  static const ink = Color(0xFF0B0D12);
  static const inkRaised = Color(0xFF171A21);

  /// Neutral text on light surfaces.
  static const textPrimary = Color(0xFF14161B);
  static const textSecondary = Color(0xFF5E636E);
  static const textMuted = Color(0xFF8C919C);

  /// Light surfaces.
  static const sheet = Colors.white;
  static const field = Color(0xFFF4F5F7);
  static const outline = Color(0xFFD5D8DE);

  /// Disabled primary button (the reference's grey "Continue").
  static const disabledFill = Color(0xFFECEDF0);
  static const disabledText = Color(0xFFA2A6B0);

  /// Status: in-progress / success pill.
  static const success = Color(0xFF16834F);
  static const successTint = Color(0xFFE3F5EB);
}
