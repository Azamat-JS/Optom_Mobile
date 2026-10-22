import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/app_l10n.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/tracking/data/tracking_disclosure_storage.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/screens/tracking_disclosure_screen.dart';

/// UI entry points for starting/stopping location sharing, so every button
/// goes through the same consent flow.
abstract final class TrackingActions {
  /// Shows the disclosure first if it was never accepted, then (and only
  /// then) asks for OS permissions and starts sharing.
  static Future<void> goOnline(BuildContext context, WidgetRef ref) async {
    final storage = getIt<TrackingDisclosureStorage>();
    if (!await storage.isAccepted()) {
      if (!context.mounted) return;
      final accepted = await TrackingDisclosureScreen.show(context);
      if (accepted != true) return;
      await storage.accept();
    }
    await ref.read(trackingNotifierProvider.notifier).goOnline();
  }

  static Future<void> goOffline(BuildContext context, WidgetRef ref) async {
    final tracking = ref.read(trackingNotifierProvider);
    final active = tracking.activeDeliveryLabel;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.trkGoOfflineTitle),
        content: Text(
          active == null
              ? context.l10n.trkGoOfflineBody
              : tracking.customerWatches
              ? context.l10n.trkGoOfflineActiveCustomer(active)
              : context.l10n.trkGoOfflineActiveOwner(active),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.l10n.trkStop)),
        ],
      ),
    );
    if (confirmed == true) await ref.read(trackingNotifierProvider.notifier).goOffline();
  }
}

/// "5 s ago"-style label for the last successful send (no BuildContext: also used
/// outside widgets).
String trackingAgoLabel(DateTime? at, DateTime now) {
  if (at == null) return appL10n.trkNotSentYet;
  final seconds = now.difference(at).inSeconds;
  if (seconds < 5) return appL10n.trkJustNow;
  if (seconds < 60) return appL10n.trkSecondsAgo('$seconds');
  return appL10n.trkMinutesAgo('${seconds ~/ 60}');
}
