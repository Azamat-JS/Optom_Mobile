import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/location/location_tracker.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/screens/tracking_disclosure_screen.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_style.dart';

/// Tracking details: current state, last send, who can see the courier right
/// now, and the stop control.
class TrackingDetailsSheet extends ConsumerWidget {
  const TrackingDetailsSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const TrackingDetailsSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingNotifierProvider);
    final theme = Theme.of(context);
    final style = TrackingStatusStyle.of(tracking.phase, theme.colorScheme);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(style.icon, color: style.color),
                const SizedBox(width: 12),
                Text(style.label, style: theme.textTheme.titleMedium?.copyWith(color: style.color)),
              ],
            ),
            const SizedBox(height: 16),
            _Row(
              icon: Icons.access_time,
              title: context.l10n.trkLastSent,
              value: trackingAgoLabel(tracking.lastSentAt, DateTime.now()),
            ),
            _Row(icon: Icons.visibility_outlined, title: context.l10n.trkWhoNow, value: tracking.watchersLabel),
            if (tracking.notificationsDenied)
              _Row(
                icon: Icons.notifications_off_outlined,
                title: context.l10n.trkNoNotifPermission,
                value: context.l10n.trkNoNotifPermissionBody,
              ),
            if (Platform.isAndroid && tracking.isOnline)
              _Row(
                icon: Icons.battery_alert_outlined,
                title: context.l10n.trkBatterySaver,
                value: context.l10n.trkBatterySaverBody,
                action: TextButton(
                  onPressed: () => getIt<LocationTracker>().openAppSettings(),
                  child: Text(context.l10n.commonSettings),
                ),
              ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => TrackingDisclosureScreen.show(context, readOnly: true),
              icon: const Icon(Icons.info_outline),
              label: Text(context.l10n.trkAboutSharing),
            ),
            if (tracking.isOnline) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    await TrackingActions.goOffline(context, ref);
                    if (context.mounted && !ref.read(trackingNotifierProvider).isOnline) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(context.l10n.trkStop),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.title, required this.value, this.action});

  final IconData icon;
  final String title;
  final String value;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
