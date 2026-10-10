import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/shared/widgets/language_picker.dart';

/// App settings (Phase 8): interface language for everyone (guest-eligible
/// route), plus logout for a signed-in user. Reached from every role's home
/// AppBar and the storefront Profil tab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(sessionNotifierProvider).valueOrNull?.user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.languageTitle, style: theme.textTheme.titleMedium),
            subtitle: Text(l10n.languageHint),
          ),
          const LanguageOptionsList(),
          if (user != null) ...[
            const Divider(),
            ListTile(title: Text(l10n.settingsAccount, style: theme.textTheme.titleMedium)),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.commonLogout),
              onTap: () => ref.read(sessionNotifierProvider.notifier).logout(),
            ),
          ],
        ],
      ),
    );
  }
}
