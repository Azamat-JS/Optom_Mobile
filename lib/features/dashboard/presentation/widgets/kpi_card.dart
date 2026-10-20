import 'package:flutter/material.dart';

import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Labelled figure tile on the dashboards (home, reports, super admin). Kept
/// as its own name for the call sites; draws a [StatTile].
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => StatTile(
    icon: icon ?? Icons.insights_rounded,
    label: label,
    value: value,
    subtitle: subtitle,
    tint: color,
    onTap: onTap,
  );
}
