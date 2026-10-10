import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/widgets/telegram_notifications_tile.dart';
import 'package:bsmart/features/auth/presentation/widgets/verify_phone_banner.dart';
import 'package:bsmart/core/l10n/l10n.dart';

/// The "Profil" tab — a guest sees login/register entry points; a logged-in
/// `CUSTOMER` sees their own orders/debts (both reused as-is from their
/// respective owner-side features — see route wiring in `app_router.dart`)
/// and can log out.
class StorefrontProfileTab extends ConsumerWidget {
  const StorefrontProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(sessionNotifierProvider).valueOrNull;
    final user = authState?.user;
    final l10n = context.l10n;
    final settingsTile = ListTile(
      leading: const Icon(Icons.settings_outlined),
      title: Text(l10n.commonSettings),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(RouteNames.settings),
    );

    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 56),
              const SizedBox(height: 12),
              Text(l10n.profileLoginPrompt, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.push(RouteNames.login), child: Text(l10n.commonLogin)),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.push(RouteNames.register),
                child: Text(l10n.commonRegister),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => context.push(RouteNames.settings),
                icon: const Icon(Icons.settings_outlined),
                label: Text(l10n.commonSettings),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(user.fullName),
          subtitle: Text(user.phone),
          trailing: user.phoneVerified
              ? Tooltip(
                  message: l10n.profilePhoneVerified,
                  child: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary),
                )
              : null,
        ),
        VerifyPhoneBanner(message: l10n.verifyBannerProfile),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: Text(l10n.profileMyOrders),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(RouteNames.orders),
        ),
        ListTile(
          leading: const Icon(Icons.delivery_dining_outlined),
          title: Text(l10n.profileMyDeliveries),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(RouteNames.customerDeliveries),
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: Text(l10n.profileMyDebts),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(RouteNames.customerDebts),
        ),
        const Divider(),
        const TelegramNotificationsTile(),
        settingsTile,
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(l10n.commonLogout),
          onTap: () => ref.read(sessionNotifierProvider.notifier).logout(),
        ),
      ],
    );
  }
}
