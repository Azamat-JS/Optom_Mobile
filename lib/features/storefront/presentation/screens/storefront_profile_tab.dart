import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

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

    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 56),
              const SizedBox(height: 12),
              const Text('Profilni koʻrish uchun tizimga kiring', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.push(RouteNames.login), child: const Text('Kirish')),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.push(RouteNames.register),
                child: const Text("Ro'yxatdan o'tish"),
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
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: const Text('Buyurtmalarim'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(RouteNames.orders),
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Qarzlarim'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(RouteNames.customerDebts),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Chiqish'),
          onTap: () => ref.read(sessionNotifierProvider.notifier).logout(),
        ),
      ],
    );
  }
}
