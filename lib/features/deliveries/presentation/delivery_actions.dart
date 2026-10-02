import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:bsmart/features/deliveries/presentation/providers/courier_deliveries_notifier.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';

/// Shared UI flows for courier delivery actions.
abstract final class DeliveryActions {
  /// Accepting starts location sharing first (through the normal consent
  /// flow) — the customer can only watch a courier who is online. Declining
  /// consent still accepts; the screen then shows a "go online" banner.
  static Future<bool> accept(BuildContext context, WidgetRef ref, Delivery delivery) async {
    if (!ref.read(trackingNotifierProvider).isOnline) await TrackingActions.goOnline(context, ref);
    final failure = await ref.read(courierDeliveriesProvider.notifier).advance(delivery.id, DeliveryAction.accept);
    if (failure != null && context.mounted) showError(context, failure.message);
    return failure == null;
  }

  static Future<bool> confirmComplete(BuildContext context, Delivery delivery) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buyurtma topshirildimi?'),
        content: Text('${delivery.label} mijozga topshirilganini tasdiqlang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Yo\'q')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ha, topshirdim')),
        ],
      ),
    );
    return ok == true;
  }

  static Future<void> call(BuildContext context, String? phone) async {
    if (phone == null || phone.isEmpty) return;
    if (!await launchUrl(Uri(scheme: 'tel', path: phone)) && context.mounted) {
      showError(context, "Qo'ng'iroq qilib bo'lmadi");
    }
  }

  /// Opens turn-by-turn navigation in Google Maps (app if installed, else browser).
  static Future<void> navigate(BuildContext context, LatLngPoint target) async {
    final uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${target.lat},${target.lng}',
      'travelmode': 'driving',
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      showError(context, "Navigatorni ochib bo'lmadi");
    }
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
