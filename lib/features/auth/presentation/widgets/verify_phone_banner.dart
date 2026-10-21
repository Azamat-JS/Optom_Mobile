import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Phase 6 prompt for a CUSTOMER whose phone isn't Telegram-verified yet. The
/// backend only shows phone-matched data (restaurant deliveries staff entered
/// for the number, debts) to a verified phone, so screens that depend on it
/// explain why they look empty. Renders nothing once verified.
class VerifyPhoneBanner extends ConsumerWidget {
  const VerifyPhoneBanner({super.key, required this.message});

  /// Full localized sentence: what verifying unlocks on this screen and the
  /// ask to verify (e.g. `l10n.verifyBannerDebts`). A whole sentence, not a
  /// fragment, so each language can order it naturally.
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionNotifierProvider).valueOrNull?.user;
    if (user == null || !user.needsPhoneVerification) return const SizedBox.shrink();
    final colors = BrandColors.of(context);
    const telegramBlue = Color(0xFF229ED9);
    // Phase 9: a white card with a Telegram-blue icon tile and a filled
    // "verify" button; it sits inside a page's own padding (no margin).
    return DashCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: telegramBlue.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.verified_user_rounded, color: telegramBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push(RouteNames.customerVerifyPhone),
            style: FilledButton.styleFrom(
              backgroundColor: telegramBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.telegram),
            label: Text(context.l10n.verifyBannerAction),
          ),
        ],
      ),
    );
  }
}
