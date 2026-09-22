import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/theme/app_motion.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: color ?? scheme.primary),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.08, end: 0);
  }
}
