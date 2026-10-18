import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_theme.dart';
import 'package:bsmart/shared/widgets/brand_mark.dart';
import 'package:bsmart/shared/widgets/language_picker.dart';

/// Shared layout of the sign-in screens: a dark brand hero (logo, tagline,
/// illustration) with a rounded white sheet below holding the form.
///
/// The whole page scrolls as one, so the form stays reachable above the
/// keyboard; the illustration folds away while the keyboard is open.
///
/// Top bar: a back button when there is somewhere to go back to, otherwise a
/// "Later" pill that lets a guest keep browsing the storefront
/// ([showSkip]); the language pill when [showLanguage].
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.child, this.showLanguage = true, this.showSkip = true, this.onBack, super.key});

  final Widget child;
  final bool showLanguage;
  final bool showSkip;

  /// Overrides the default back action ([Navigator.maybePop]).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Theme(
      data: AuthTheme.of(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: AppColors.ink,
          body: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: _Hero(
                  showLanguage: showLanguage,
                  showSkip: showSkip,
                  onBack: onBack,
                  showIllustration: !keyboardOpen,
                ),
              ),
              SliverFillRemaining(hasScrollBody: false, child: _Sheet(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.showLanguage,
    required this.showSkip,
    required this.onBack,
    required this.showIllustration,
  });

  final bool showLanguage;
  final bool showSkip;
  final VoidCallback? onBack;
  final bool showIllustration;

  @override
  Widget build(BuildContext context) {
    final canPop = onBack != null || Navigator.of(context).canPop();
    return ClipRect(
      child: Stack(
        children: [
          // Soft yellow glow behind the logo.
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.brandYellow.withValues(alpha: 0.16), AppColors.brandYellow.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (canPop)
                          _HeroIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                          ),
                        const Spacer(),
                        if (showLanguage) const LanguagePickerButton(onDark: true),
                        if (showSkip && !canPop) ...[
                          const SizedBox(width: 8),
                          _HeroPill(label: context.l10n.authSkip, onPressed: () => context.go(RouteNames.customerHome)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const BrandMark(width: 150),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    context.l10n.authTagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                  ),
                ).animate().fadeIn(delay: AppMotion.fast, duration: AppMotion.slow),
                AnimatedSize(
                  duration: AppMotion.standard,
                  curve: AppMotion.emphasized,
                  child: showIllustration
                      ? const Padding(padding: EdgeInsets.only(top: 22), child: _Illustration())
                      : const SizedBox(width: double.infinity, height: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three business "tiles" (store, delivery, debt book) peeking out from
/// behind the sheet — the counterpart of the reference's product photos.
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: 132,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Tile(
              icon: Icons.storefront_rounded,
              size: 84,
              top: 30,
              angle: -0.14,
              fill: AppColors.brandYellow,
              iconColor: AppColors.onBrand,
              delay: 0,
            ),
            const SizedBox(width: 14),
            _Tile(
              icon: Icons.local_shipping_rounded,
              size: 106,
              top: 0,
              angle: 0,
              fill: Colors.white,
              iconColor: AppColors.goldInk,
              delay: 1,
            ),
            const SizedBox(width: 14),
            _Tile(
              icon: Icons.receipt_long_rounded,
              size: 84,
              top: 30,
              angle: 0.14,
              fill: AppColors.inkRaised,
              iconColor: AppColors.brandYellow,
              border: AppColors.brandYellow.withValues(alpha: 0.35),
              delay: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.size,
    required this.top,
    required this.angle,
    required this.fill,
    required this.iconColor,
    required this.delay,
    this.border,
  });

  final IconData icon;
  final double size;
  final double top;
  final double angle;
  final Color fill;
  final Color iconColor;
  final Color? border;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: EdgeInsets.only(top: top),
          child: Transform.rotate(
            angle: angle,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(size * 0.26),
                border: border == null ? null : Border.all(color: border!, width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
              child: Icon(icon, size: size * 0.46, color: iconColor),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: AppMotion.fast * (delay + 1), duration: AppMotion.slow)
        .slideY(begin: 0.35, end: 0, curve: AppMotion.emphasized, duration: AppMotion.slow)
        // Gentle idle float.
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: -5, duration: (2200 + delay * 300).ms, curve: Curves.easeInOut);
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.sheet,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + MediaQuery.paddingOf(context).bottom),
          child: child,
        )
        .animate()
        .fadeIn(duration: AppMotion.standard)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.slow, curve: AppMotion.emphasized);
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        fixedSize: const Size(40, 40),
        minimumSize: const Size(40, 40),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontFamily: AuthTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
