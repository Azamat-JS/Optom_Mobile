import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/l10n/locale_provider.dart';
import 'package:bsmart/core/router/app_router.dart';
import 'package:bsmart/core/theme/app_theme.dart';

class BsmartApp extends ConsumerWidget {
  const BsmartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'bsmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      // uz/ru/en (Phase 8) — strings from lib/l10n/*.arb via gen-l10n; the
      // delegates also localize Material widgets (date pickers, tooltips…).
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
