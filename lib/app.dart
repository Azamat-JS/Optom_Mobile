import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/router/app_router.dart';
import 'package:bsmart/core/theme/app_theme.dart';

class BsmartApp extends ConsumerWidget {
  const BsmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'bsmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      // Uzbek-only UI for Phase 1 — no localization delegates needed yet
      // (see the implementation plan's cross-cutting rules).
    );
  }
}
