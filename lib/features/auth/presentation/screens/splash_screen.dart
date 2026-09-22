import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

/// Shown while [sessionNotifierProvider] resolves the restored session on
/// cold start. Navigation itself is entirely driven by `app_router.dart`'s
/// redirect — this screen never calls `context.go(...)` — so there's a
/// single source of truth for "where should we be right now."
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(sessionNotifierProvider);

    return Scaffold(
      body: Center(
        child: authState.when(
          data: (_) => const CircularProgressIndicator(),
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Ilovani ishga tushirishda xatolik yuz berdi.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(sessionNotifierProvider),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
