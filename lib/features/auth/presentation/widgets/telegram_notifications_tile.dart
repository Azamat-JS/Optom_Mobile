import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_notification_settings.dart';
import 'package:bsmart/features/auth/presentation/providers/telegram_notifications_notifier.dart';
import 'package:bsmart/core/l10n/l10n.dart';

/// "Telegram bildirishnomalari" in Profil (Phase 7 N3): a switch once the verify bot can message
/// this account; otherwise a way to link it — verifying the phone through the bot links the chat
/// (also for a customer verified earlier through the Mini App, who never started the verify bot).
class TelegramNotificationsTile extends ConsumerWidget {
  const TelegramNotificationsTile({super.key, this.forCourier = false});

  /// What the messages are about — customers and couriers hear about different things.
  final bool forCourier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(telegramNotificationsProvider);
    final l10n = context.l10n;
    final title = Text(l10n.tgNotifTitle);
    final enabledText = forCourier ? l10n.tgNotifCourierEnabled : l10n.tgNotifCustomerEnabled;
    final linkText = forCourier ? l10n.tgNotifCourierLink : l10n.tgNotifCustomerLink;
    return settings.when(
      loading: () => ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: title,
        trailing: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      // A secondary setting — don't block the profile when it can't load.
      error: (_, _) => const SizedBox.shrink(),
      data: (s) {
        if (!s.linked) {
          return ListTile(
            leading: const Icon(Icons.notifications_off_outlined),
            title: title,
            subtitle: Text(linkText),
            trailing: TextButton(
              // Re-read when the verify screen closes: an already-verified account (e.g. a courier)
              // doesn't change `phoneVerified`, so nothing else would notice the new link.
              onPressed: () async {
                await context.push(RouteNames.customerVerifyPhone);
                ref.invalidate(telegramNotificationsProvider);
              },
              child: Text(l10n.tgNotifConnect),
            ),
          );
        }
        return SwitchListTile(
          secondary: Icon(s.enabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined),
          title: title,
          subtitle: Text(s.enabled ? enabledText : l10n.tgNotifOff),
          value: s.enabled,
          onChanged: (v) async {
            final failure = await ref.read(telegramNotificationsProvider.notifier).setEnabled(v);
            if (failure != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
            }
          },
        );
      },
    );
  }
}

/// Courier AppBar bell (Phase 7 N4): shows whether job alerts reach Telegram and opens the
/// switch / "Ulash" in a sheet.
class CourierAlertsButton extends ConsumerWidget {
  const CourierAlertsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(telegramNotificationsProvider).valueOrNull;
    final l10n = context.l10n;
    final (icon, tooltip) = switch (s) {
      null => (Icons.notifications_none, l10n.tgNotifTitle),
      TelegramNotificationSettings(linked: false) => (Icons.notification_add_outlined, l10n.tgNotifLinkTelegram),
      TelegramNotificationSettings(enabled: true) => (Icons.notifications_active, l10n.tgNotifEnabled),
      _ => (Icons.notifications_off_outlined, l10n.tgNotifDisabled),
    };
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () {
        // Fresh state each time: the link can drop server-side (bot blocked → chat cleared).
        ref.invalidate(telegramNotificationsProvider);
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: TelegramNotificationsTile(forCourier: true),
            ),
          ),
        );
      },
    );
  }
}
