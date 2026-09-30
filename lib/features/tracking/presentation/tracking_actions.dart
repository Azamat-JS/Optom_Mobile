import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Oflayn bo'lish"),
        content: const Text(
          "Joylashuvingizni ulashish to'xtatiladi — biznes egangiz sizni xaritada ko'rmaydi.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text("To'xtatish")),
        ],
      ),
    );
    if (confirmed == true) await ref.read(trackingNotifierProvider.notifier).goOffline();
  }
}

/// "5 soniya oldin"-style label for the last successful send.
String trackingAgoLabel(DateTime? at, DateTime now) {
  if (at == null) return 'hali yuborilmagan';
  final seconds = now.difference(at).inSeconds;
  if (seconds < 5) return 'hozirgina';
  if (seconds < 60) return '$seconds soniya oldin';
  return '${seconds ~/ 60} daqiqa oldin';
}
