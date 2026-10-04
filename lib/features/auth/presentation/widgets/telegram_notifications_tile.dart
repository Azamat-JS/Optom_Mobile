import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_notification_settings.dart';
import 'package:bsmart/features/auth/presentation/providers/telegram_notifications_notifier.dart';

/// "Telegram bildirishnomalari" in Profil (Phase 7 N3): a switch once the verify bot can message
/// this account; otherwise a way to link it — verifying the phone through the bot links the chat
/// (also for a customer verified earlier through the Mini App, who never started the verify bot).
class TelegramNotificationsTile extends ConsumerWidget {
  const TelegramNotificationsTile({
    super.key,
    this.enabledText = 'Kuryer buyurtmani olganda, yetib kelganda va topshirganda xabar keladi',
    this.linkText = "Buyurtmangiz yo'lga chiqqanda xabar olish uchun raqamingizni Telegram orqali tasdiqlang",
  });

  /// What the messages are about — customers and couriers hear about different things.
  final String enabledText;
  final String linkText;

  static const _title = Text('Telegram bildirishnomalari');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(telegramNotificationsProvider);
    return settings.when(
      loading: () => const ListTile(
        leading: Icon(Icons.notifications_outlined),
        title: _title,
        trailing: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      // A secondary setting — don't block the profile when it can't load.
      error: (_, _) => const SizedBox.shrink(),
      data: (s) {
        if (!s.linked) {
          return ListTile(
            leading: const Icon(Icons.notifications_off_outlined),
            title: _title,
            subtitle: Text(linkText),
            trailing: TextButton(
              // Re-read when the verify screen closes: an already-verified account (e.g. a courier)
              // doesn't change `phoneVerified`, so nothing else would notice the new link.
              onPressed: () async {
                await context.push(RouteNames.customerVerifyPhone);
                ref.invalidate(telegramNotificationsProvider);
              },
              child: const Text('Ulash'),
            ),
          );
        }
        return SwitchListTile(
          secondary: Icon(s.enabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined),
          title: _title,
          subtitle: Text(s.enabled ? enabledText : "O'chirilgan"),
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
    final (icon, tooltip) = switch (s) {
      null => (Icons.notifications_none, 'Telegram bildirishnomalari'),
      TelegramNotificationSettings(linked: false) => (Icons.notification_add_outlined, 'Telegramni ulash'),
      TelegramNotificationSettings(enabled: true) => (Icons.notifications_active, 'Bildirishnomalar yoqilgan'),
      _ => (Icons.notifications_off_outlined, "Bildirishnomalar o'chirilgan"),
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
              child: TelegramNotificationsTile(
                enabledText: 'Sizga yetkazish biriktirilsa, taklif qilinsa yoki bekor qilinsa xabar keladi',
                linkText: "Yangi yetkazishlar haqida Telegram'da xabar olish uchun raqamingizni tasdiqlang",
              ),
            ),
          ),
        );
      },
    );
  }
}
