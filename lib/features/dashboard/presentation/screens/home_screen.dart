import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

/// Placeholder landing screen after login — the real seller/retailer
/// dashboards (reporting charts, KPI cards, UZS/USD toggle) are the rest of
/// Milestone 1, not yet built. This exists so the auth flow (login → session
/// restore → role-aware landing → logout) is demonstrably working end to end
/// against the live backend before layering more screens on top.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(sessionNotifierProvider).valueOrNull;
    final user = authState?.user;
    final role = authState?.session?.role;

    final roleLabel = switch (role) {
      UserRole.seller || UserRole.sellerAdmin => 'Optomchi',
      UserRole.retailer || UserRole.retailerAdmin => "Do'konchi",
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('bsmart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Chiqish',
            onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: Theme.of(context).colorScheme.primary)
                .animate()
                .scale(duration: const Duration(milliseconds: 400)),
            const SizedBox(height: 16),
            Text(
              'Xush kelibsiz, ${user?.fullName ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().fadeIn(),
            if (roleLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(roleLabel, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (user?.shopName != null) ...[
              const SizedBox(height: 4),
              Text(user!.shopName!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
