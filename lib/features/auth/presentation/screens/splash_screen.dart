import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/brand_mark.dart';
import 'package:bsmart/core/l10n/l10n.dart';

/// Shown while [sessionNotifierProvider] resolves the restored session on
/// cold start. Navigation itself is entirely driven by `app_router.dart`'s
/// redirect — this screen never calls `context.go(...)` — so there's a
/// single source of truth for "where should we be right now."
///
/// Brand screen: the logo on the hero black; its [BrandMark] hero then flies
/// into the login/register header.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(sessionNotifierProvider);

    return Theme(
      data: BrandTheme.build(Brightness.dark),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        child: Scaffold(
          backgroundColor: AppColors.ink,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  const BrandMark(width: 210)
                      .animate()
                      .fadeIn(duration: AppMotion.slow)
                      .scale(begin: const Offset(0.92, 0.92), duration: AppMotion.slow, curve: AppMotion.emphasized),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.authTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: BrandTheme.fontFamily,
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ).animate().fadeIn(delay: AppMotion.standard, duration: AppMotion.slow),
                  const Spacer(flex: 4),
                  SizedBox(
                    height: 120,
                    child: authState.hasError && !authState.isLoading
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                context.l10n.splashError,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 14),
                              FilledButton(
                                onPressed: () => ref.invalidate(sessionNotifierProvider),
                                child: Text(context.l10n.commonRetry),
                              ),
                            ],
                          ).animate().fadeIn(duration: AppMotion.standard)
                        // Delayed, so a fast session restore never flashes a spinner.
                        : const Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.brandYellow),
                            ),
                          ).animate().fadeIn(delay: 700.ms, duration: AppMotion.standard),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
