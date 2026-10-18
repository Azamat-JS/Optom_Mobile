import 'package:flutter/material.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';

/// App-wide Material 3 theme in the bsmart brand (Phase 9): Manrope, the
/// logo's yellow and near-black, neutral greys.
///
/// This is the theme every not-yet-redesigned screen gets. Redesigned
/// screens wrap themselves in [BrandTheme], whose buttons are full width.
/// Here buttons keep their natural size, so existing rows of buttons keep
/// laying out as before.
///
/// Colour roles:
/// - `primary` is the brand colour for text, icons, charts, switches and
///   focus: dark gold in light mode (logo yellow is unreadable on white),
///   logo yellow in dark mode.
/// - Filled buttons, the FAB and the selected navigation item are always
///   logo yellow with near-black content, set explicitly below.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ColorScheme scheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final c = isDark ? BrandColors.dark : BrandColors.light;
    final seeded = ColorScheme.fromSeed(seedColor: AppColors.brandYellow, brightness: brightness);
    return seeded.copyWith(
      primary: isDark ? AppColors.brandYellow : AppColors.goldInk,
      onPrimary: isDark ? AppColors.onBrand : Colors.white,
      primaryContainer: isDark ? const Color(0xFF3A2F0A) : const Color(0xFFFFF0B8),
      onPrimaryContainer: isDark ? AppColors.brandYellow : const Color(0xFF3D2A00),
      secondary: isDark ? AppColors.brandYellow : AppColors.goldInk,
      onSecondary: isDark ? AppColors.onBrand : Colors.white,
      secondaryContainer: isDark ? const Color(0xFF3A2F0A) : const Color(0xFFFFE89A),
      onSecondaryContainer: isDark ? const Color(0xFFFFE08A) : AppColors.onBrand,
      tertiary: c.success,
      error: isDark ? const Color(0xFFFF8A80) : const Color(0xFFC62828),
      onError: Colors.white,
      surface: c.sheet,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: isDark ? const Color(0xFF0E1014) : Colors.white,
      surfaceContainerLow: isDark ? const Color(0xFF16181E) : const Color(0xFFF8F9FA),
      surfaceContainer: isDark ? const Color(0xFF1B1E25) : const Color(0xFFF4F5F7),
      surfaceContainerHigh: isDark ? const Color(0xFF22252D) : const Color(0xFFEEEFF2),
      surfaceContainerHighest: isDark ? const Color(0xFF2A2E37) : const Color(0xFFE8E9ED),
      outline: c.outline,
      outlineVariant: isDark ? const Color(0xFF262A32) : const Color(0xFFE6E8EC),
      surfaceTint: Colors.transparent,
      inverseSurface: AppColors.inkRaised,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.brandYellow,
    );
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final c = isDark ? BrandColors.dark : BrandColors.light;
    final cs = scheme(brightness);
    const font = BrandTheme.fontFamily;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: font,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    final text = base.textTheme.apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);
    final radius = BorderRadius.circular(14);
    OutlineInputBorder border(Color color, [double width = 1.2]) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
    WidgetStateProperty<Color?> yellowFill() => WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled) ? c.disabledFill : AppColors.brandYellow,
    );
    WidgetStateProperty<Color?> onYellow() => WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled) ? c.disabledText : AppColors.onBrand,
    );

    return base.copyWith(
      extensions: [c],
      scaffoldBackgroundColor: c.sheet,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.sheet,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.6,
        shadowColor: Colors.black26,
        titleTextStyle: TextStyle(
          fontFamily: font,
          color: c.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? cs.surfaceContainer : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: radius)),
          elevation: const WidgetStatePropertyAll(0),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          backgroundColor: yellowFill(),
          foregroundColor: onYellow(),
          iconColor: onYellow(),
          overlayColor: WidgetStatePropertyAll(AppColors.onBrand.withValues(alpha: 0.08)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          backgroundColor: cs.surfaceContainerLow,
          foregroundColor: cs.primary,
          elevation: 0,
          textStyle: const TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: c.outline, width: 1.2),
          foregroundColor: c.textPrimary,
          textStyle: const TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: const TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: c.textPrimary)),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandYellow,
        foregroundColor: AppColors.onBrand,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedTextStyle: const TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w800),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.sheet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.brandYellow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? AppColors.onBrand : c.textMuted),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: font,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
            color: states.contains(WidgetState.selected) ? c.textPrimary : c.textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.sheet,
        indicatorColor: AppColors.brandYellow,
        selectedIconTheme: const IconThemeData(color: AppColors.onBrand),
        unselectedIconTheme: IconThemeData(color: c.textMuted),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: c.sheet, surfaceTintColor: Colors.transparent),
      tabBarTheme: TabBarThemeData(
        labelColor: c.textPrimary,
        unselectedLabelColor: c.textSecondary,
        indicatorColor: isDark ? AppColors.brandYellow : AppColors.brandAmber,
        dividerColor: cs.outlineVariant,
        labelStyle: const TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontFamily: font, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: c.outline),
        selectedColor: cs.secondaryContainer,
        labelStyle: TextStyle(fontFamily: font, color: c.textPrimary, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: border(c.outline),
        enabledBorder: border(c.outline),
        focusedBorder: border(isDark ? AppColors.brandYellow : AppColors.brandAmber, 1.8),
        errorBorder: border(cs.error),
        focusedErrorBorder: border(cs.error, 1.8),
        labelStyle: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: c.accentText, fontWeight: FontWeight.w700),
        hintStyle: TextStyle(color: c.textMuted, fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(fontFamily: font, color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.sheet,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        dragHandleColor: c.outline,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        titleTextStyle: TextStyle(fontFamily: font, color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.primary),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inkRaised,
        contentTextStyle: const TextStyle(fontFamily: font, color: Colors.white, fontWeight: FontWeight.w600),
        actionTextColor: AppColors.brandYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      badgeTheme: const BadgeThemeData(backgroundColor: AppColors.ink, textColor: Colors.white),
    );
  }
}
