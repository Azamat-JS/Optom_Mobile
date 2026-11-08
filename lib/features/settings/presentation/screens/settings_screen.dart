import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/l10n/locale_provider.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/theme/theme_mode_provider.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// App settings (Phase 8): interface language and light/dark theme for everyone
/// (guest-eligible route), plus logout for a signed-in user. Reached from every role's home
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
    final themeMode = ref.watch(themeModeProvider);
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
          _OptionsCard(
            children: [
              for (final code in supportedLanguageCodes)
                _OptionRow(
                  selected: code == current,
                  onTap: () => ref.read(localeProvider.notifier).setLanguage(code),
                  leading: Text(
                    code.toUpperCase(),
                    style: TextStyle(
                      color: code == current ? AppColors.onBrand : colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  label: languageNames[code]!,
                ),
            ],
          ),
          DashSectionTitle(l10n.themeTitle),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
            child: Text(
              l10n.themeHint,
              style: TextStyle(color: colors.textMuted, fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          _OptionsCard(
            children: [
              for (final mode in themeModeChoices)
                _OptionRow(
                  selected: mode == themeMode,
                  onTap: () => ref.read(themeModeProvider.notifier).setMode(mode),
                  leading: Icon(
                    switch (mode) {
                      ThemeMode.system => Icons.brightness_auto_rounded,
                      ThemeMode.light => Icons.light_mode_rounded,
                      ThemeMode.dark => Icons.dark_mode_rounded,
                    },
                    size: 20,
                    color: mode == themeMode ? AppColors.onBrand : colors.textSecondary,
                  ),
                  label: switch (mode) {
                    ThemeMode.system => l10n.themeSystem,
                    ThemeMode.light => l10n.themeLight,
                    ThemeMode.dark => l10n.themeDark,
                  },
                ),
            ],
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

/// A card of selectable rows separated by hairlines (languages, themes).
class _OptionsCard extends StatelessWidget {
  const _OptionsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final outline = BrandColors.of(context).outline;
    return DashCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) Divider(height: 1, indent: 64, color: outline),
            child,
          ],
        ],
      ),
    );
  }
}

/// One choice: a tile (yellow when selected) with [leading], the [label], and a check.
class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.selected, required this.onTap, required this.leading, required this.label});

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.brandYellow : DashColors.inset(context),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: leading,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: colors.accentText),
            ],
          ),
        ),
      ),
    );
  }
}
