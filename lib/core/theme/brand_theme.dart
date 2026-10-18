import 'package:flutter/material.dart';

import 'package:bsmart/core/theme/app_colors.dart';

/// Surface/text colours of brand-themed screens (auth, storefront), for light
/// and dark mode. Dark heroes are always [AppColors.ink], whatever the
/// brightness.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.sheet,
    required this.field,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentText,
    required this.disabledFill,
    required this.disabledText,
    required this.success,
    required this.successTint,
    required this.errorTint,
  });

  final Color sheet;
  final Color field;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Brand-coloured text: gold on light, logo yellow on dark.
  final Color accentText;
  final Color disabledFill;
  final Color disabledText;
  final Color success;
  final Color successTint;
  final Color errorTint;

  static const light = BrandColors(
    sheet: AppColors.sheet,
    field: AppColors.field,
    outline: AppColors.outline,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    accentText: AppColors.goldInk,
    disabledFill: AppColors.disabledFill,
    disabledText: AppColors.disabledText,
    success: AppColors.success,
    successTint: AppColors.successTint,
    errorTint: Color(0xFFFDECEC),
  );

  static const dark = BrandColors(
    sheet: Color(0xFF121419),
    field: Color(0xFF1B1E25),
    outline: Color(0xFF343843),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFFA9AEB8),
    textMuted: Color(0xFF7D828C),
    accentText: AppColors.brandYellow,
    disabledFill: Color(0xFF23262D),
    disabledText: Color(0xFF6B707A),
    success: Color(0xFF4CC38A),
    successTint: Color(0xFF12301F),
    errorTint: Color(0xFF3A1D1F),
  );

  static BrandColors of(BuildContext context) => Theme.of(context).extension<BrandColors>() ?? light;

  @override
  BrandColors copyWith() => this;

  @override
  BrandColors lerp(BrandColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// Brand theme (Phase 9 redesign): Manrope, yellow filled buttons, outlined
/// fields with a floating gold label, built from [AppColors]. Applied locally
/// to the redesigned screens (auth flow, storefront catalog) while the global
/// `AppTheme` still serves the rest of the app.
///
/// Filled/outlined buttons default to full width (`Size.fromHeight(56)`):
/// give a button inside a `Row` its own `minimumSize`.
abstract final class BrandTheme {
  static const fontFamily = 'Manrope';

  static ThemeData of(BuildContext context) => build(Theme.of(context).brightness);

  static ThemeData build(Brightness brightness) {
    final c = brightness == Brightness.dark ? BrandColors.dark : BrandColors.light;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.brandYellow,
      onPrimary: AppColors.onBrand,
      secondary: c.accentText,
      onSecondary: c.sheet,
      error: brightness == Brightness.dark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
      onError: Colors.white,
      surface: c.sheet,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.outline,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: fontFamily);
    final text = base.textTheme.apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);
    final radius = BorderRadius.circular(14);
    OutlineInputBorder border(Color color, [double width = 1.2]) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );

    return base.copyWith(
      extensions: [c],
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4, height: 1.2),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        bodyMedium: text.bodyMedium?.copyWith(color: c.textSecondary, height: 1.4),
        bodySmall: text.bodySmall?.copyWith(color: c.textMuted, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: border(c.outline),
        enabledBorder: border(c.outline),
        focusedBorder: border(AppColors.brandAmber, 1.8),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 1.8),
        labelStyle: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: c.accentText, fontWeight: FontWeight.w700),
        hintStyle: TextStyle(color: c.textMuted, fontWeight: FontWeight.w500),
        helperStyle: TextStyle(color: c.textMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(56)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: radius)),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.1),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? c.disabledFill : AppColors.brandYellow,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? c.disabledText : AppColors.onBrand,
          ),
          overlayColor: WidgetStatePropertyAll(AppColors.onBrand.withValues(alpha: 0.08)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: c.outline, width: 1.2),
          foregroundColor: c.textPrimary,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentText,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accentText),
      dividerTheme: DividerThemeData(color: c.outline, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inkRaised,
        contentTextStyle: const TextStyle(fontFamily: fontFamily, color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.sheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: TextStyle(fontFamily: fontFamily, color: c.textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
