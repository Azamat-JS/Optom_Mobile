import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/location/location_tracker.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_state.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_pill.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_style.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Courier's online/offline switch (with the live [TrackingStatusPill] while
/// online), plus an inline fix-it banner when location can't be shared
/// (permission denied, GPS off).
class CourierOnlineCard extends ConsumerWidget {
  const CourierOnlineCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingNotifierProvider);
    final colors = BrandColors.of(context);
    final style = TrackingStatusStyle.of(tracking.phase, Theme.of(context).colorScheme);
    final busy = tracking.phase == TrackingPhase.starting;
    void toggle(bool on) => on ? TrackingActions.goOnline(context, ref) : TrackingActions.goOffline(context, ref);

    return Column(
      children: [
        AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            // Online: the card takes a tint of the sharing state's colour.
            color: tracking.isOnline
                ? Color.alphaBlend(style.color.withValues(alpha: 0.12), DashColors.card(context))
                : DashColors.card(context),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: tracking.isOnline ? style.color : DashColors.inset(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tracking.isOnline ? Icons.delivery_dining_rounded : Icons.bedtime_rounded,
                      color: tracking.isOnline ? Colors.white : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tracking.isOnline ? 'Onlayn' : 'Oflayn',
                          style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          tracking.isOnline ? "Ko'radi: ${tracking.watchersLabel}" : "Ishni boshlash uchun onlayn bo'ling",
                          style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Switch(value: tracking.isOnline, onChanged: busy ? null : toggle),
                ],
              ),
              // Live sharing state ("5 soniya oldin"); tap opens the details sheet.
              if (tracking.isOnline) ...[
                const SizedBox(height: 8),
                const Padding(padding: EdgeInsets.only(left: 50), child: TrackingStatusPill()),
              ],
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: AppMotion.standard,
          child: tracking.hasProblem ? _ProblemBanner(phase: tracking.phase) : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ProblemBanner extends ConsumerWidget {
  const _ProblemBanner({required this.phase});

  final TrackingPhase phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = getIt<LocationTracker>();
    final theme = Theme.of(context);
    final (message, actionLabel, action) = switch (phase) {
      TrackingPhase.servicesDisabled => (
          "Telefoningizda GPS (joylashuv) o'chirilgan.",
          'GPS ni yoqish',
          tracker.openLocationSettings,
        ),
      TrackingPhase.permissionDeniedForever => (
          'Joylashuv ruxsati rad etilgan. Sozlamalardan ruxsat bering.',
          'Sozlamalarni ochish',
          tracker.openAppSettings,
        ),
      _ => (
          'Onlayn bo\'lish uchun joylashuv ruxsati kerak.',
          'Qayta urinish',
          () => TrackingActions.goOnline(context, ref),
        ),
    };
    final error = theme.colorScheme.error;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
      decoration: BoxDecoration(color: error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: error, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: action,
            style: TextButton.styleFrom(foregroundColor: error),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
