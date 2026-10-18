import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_theme.dart';

/// Bold sheet title ("Raqamingizni kiriting") with an optional muted line.
class AuthSheetHeader extends StatelessWidget {
  const AuthSheetHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        if (subtitle != null) ...[const SizedBox(height: 6), Text(subtitle!, style: theme.textTheme.bodyMedium)],
      ],
    ).animate().fadeIn(delay: AppMotion.fast, duration: AppMotion.standard);
  }
}

/// "—— yoki ——" separator.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w600),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
