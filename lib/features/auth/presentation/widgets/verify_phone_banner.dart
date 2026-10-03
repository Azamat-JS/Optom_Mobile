import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

/// Phase 6 prompt for a CUSTOMER whose phone isn't Telegram-verified yet. The
/// backend only shows phone-matched data (restaurant deliveries staff entered
/// for the number, debts) to a verified phone, so screens that depend on it
/// explain why they look empty. Renders nothing once verified.
class VerifyPhoneBanner extends ConsumerWidget {
  const VerifyPhoneBanner({super.key, required this.reason});

  /// What verifying unlocks on this screen, e.g. "Qarzlaringizni ko'rish uchun".
  final String reason;

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
                    '$reason telefon raqamingizni Telegram orqali tasdiqlang.',
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
                label: const Text('Raqamni tasdiqlash'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
