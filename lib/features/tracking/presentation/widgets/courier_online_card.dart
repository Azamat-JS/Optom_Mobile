import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/location/location_tracker.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_state.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_style.dart';

/// Courier's online/offline switch, plus an inline fix-it banner when
/// location can't be shared (permission denied, GPS off).
class CourierOnlineCard extends ConsumerWidget {
  const CourierOnlineCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingNotifierProvider);
    final theme = Theme.of(context);
    final style = TrackingStatusStyle.of(tracking.phase, theme.colorScheme);
    final busy = tracking.phase == TrackingPhase.starting;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.emphasized,
            decoration: BoxDecoration(
              color: tracking.isOnline ? style.color.withValues(alpha: 0.08) : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              value: tracking.isOnline,
              onChanged: busy
                  ? null
                  : (on) => on ? TrackingActions.goOnline(context, ref) : TrackingActions.goOffline(context, ref),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              secondary: Icon(tracking.isOnline ? Icons.delivery_dining : Icons.bedtime_outlined, color: style.color),
              title: Text(
                tracking.isOnline ? 'Onlayn' : 'Oflayn',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                tracking.isOnline
                    ? "Joylashuvingiz biznes egangizga ko'rinadi"
                    : 'Ishni boshlash uchun onlayn bo\'ling',
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: AppMotion.standard,
            child: tracking.hasProblem ? _ProblemBanner(phase: tracking.phase) : const SizedBox.shrink(),
          ),
        ],
      ),
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
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: theme.colorScheme.onErrorContainer))),
          TextButton(onPressed: action, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
