import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/l10n/locale_provider.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// App settings (Phase 8): interface language for everyone (guest-eligible
/// route), plus logout for a signed-in user. Reached from every role's home
/// AppBar and the storefront Profil tab.
///
/// Phase 9 U4c5: profile card (signed in), the languages as selectable rows
/// in a card, and a red outlined logout button.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final authState = ref.watch(sessionNotifierProvider).valueOrNull;
    final user = authState?.user;
    final role = authState?.session?.role;
    final current = ref.watch(localeProvider).languageCode;
    final error = Theme.of(context).colorScheme.error;

    return DashPage(
      title: l10n.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          if (user != null)
            DashCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  DashAvatar(name: user.firstName, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          [
                            if (role != null) role.localizedLabel(l10n),
                            if (user.phone.isNotEmpty) user.phone,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          DashSectionTitle(l10n.languageTitle),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Text(
              l10n.languageHint,
              style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          DashCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final (i, code) in supportedLanguageCodes.indexed) ...[
                  if (i > 0) Divider(height: 1, indent: 64, color: colors.outline),
                  Semantics(
                    selected: code == current,
                    button: true,
                    child: InkWell(
                      onTap: () => ref.read(localeProvider.notifier).setLanguage(code),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: code == current ? AppColors.brandYellow : DashColors.inset(context),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Text(
                                code.toUpperCase(),
                                style: TextStyle(
                                  color: code == current ? AppColors.onBrand : colors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                languageNames[code]!,
                                style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (code == current) Icon(Icons.check_circle_rounded, color: colors.accentText),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (user != null) ...[
            DashSectionTitle(l10n.settingsAccount),
            OutlinedButton.icon(
              onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(
                foregroundColor: error,
                side: BorderSide(color: error.withValues(alpha: 0.5)),
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(l10n.commonLogout),
            ),
          ],
        ],
      ),
    );
  }
}
