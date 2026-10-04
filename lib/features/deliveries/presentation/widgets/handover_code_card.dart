import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/theme/app_motion.dart';

/// Customer-side: the 4-digit code to tell the courier at the door (Phase 7 N2). The server only
/// sends it to the customer, and only while the courier has the order.
class HandoverCodeCard extends StatelessWidget {
  const HandoverCodeCard({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.pin_outlined, color: theme.colorScheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Topshirish kodi', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
                Text(
                  'Buyurtmani olganingizda kuryerga ayting. Boshqa hech kimga bermang.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: 'Kod ${code.split('').join(' ')}',
            child: Text(
              code,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 6,
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.standard).scale(begin: const Offset(0.97, 0.97), curve: AppMotion.emphasized);
  }
}
