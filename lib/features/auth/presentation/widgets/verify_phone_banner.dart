import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/core/l10n/l10n.dart';

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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user_outlined, color: scheme.onTertiaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: scheme.onTertiaryContainer),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => context.push(RouteNames.customerVerifyPhone),
                icon: const Icon(Icons.telegram),
                label: Text(context.l10n.verifyBannerAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
