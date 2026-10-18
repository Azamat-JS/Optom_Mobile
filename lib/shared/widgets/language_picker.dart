import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/l10n/locale_provider.dart';

/// Compact language switch (globe + current code) for the auth screens, where
/// a not-yet-logged-in user has no way to reach Settings.
///
/// [onDark] renders it as a translucent white pill for the dark auth hero.
class LanguagePickerButton extends ConsumerWidget {
  const LanguagePickerButton({this.onDark = false, super.key});

  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.language, size: 18, color: onDark ? Colors.white : null),
        const SizedBox(width: 6),
        Text(
          current.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: onDark ? Colors.white : null,
            fontWeight: onDark ? FontWeight.w700 : null,
          ),
        ),
      ],
    );
    return PopupMenuButton<String>(
      tooltip: context.l10n.languageChange,
      initialValue: current,
      onSelected: (code) => ref.read(localeProvider.notifier).setLanguage(code),
      itemBuilder: (_) => [
        for (final code in supportedLanguageCodes)
          CheckedPopupMenuItem(value: code, checked: code == current, child: Text(languageNames[code]!)),
      ],
      child: onDark
          ? Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: row,
            )
          : Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: row),
    );
  }
}

/// Full radio list for the Settings screen.
class LanguageOptionsList extends ConsumerWidget {
  const LanguageOptionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;
    return RadioGroup<String>(
      groupValue: current,
      onChanged: (code) {
        if (code != null) ref.read(localeProvider.notifier).setLanguage(code);
      },
      child: Column(
        children: [
          for (final code in supportedLanguageCodes)
            RadioListTile<String>(value: code, title: Text(languageNames[code]!)),
        ],
      ),
    );
  }
}
