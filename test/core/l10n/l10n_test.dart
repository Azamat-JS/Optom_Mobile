import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/l10n/locale_provider.dart';
import 'package:bsmart/shared/widgets/language_picker.dart';

Set<String> _keys(String locale) {
  final json = jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync()) as Map<String, dynamic>;
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  group('resolveInitialLanguage', () {
    test('saved choice wins', () => expect(resolveInitialLanguage('en', 'ru'), 'en'));
    test('falls back to a supported device language', () => expect(resolveInitialLanguage(null, 'ru'), 'ru'));
    test('unsupported device language → Uzbek', () => expect(resolveInitialLanguage(null, 'de'), 'uz'));
    test('ignores a stale/unknown saved value', () => expect(resolveInitialLanguage('fr', 'en'), 'en'));
  });

  test('ru/en ARB files define exactly the keys of the uz template', () {
    final template = _keys('uz');
    for (final locale in ['ru', 'en']) {
      final keys = _keys(locale);
      expect(template.difference(keys), isEmpty, reason: '$locale is missing keys');
      expect(keys.difference(template), isEmpty, reason: '$locale has stale keys');
    }
  });

  test('every role has a non-empty label in every language', () async {
    for (final code in supportedLanguageCodes) {
      final l10n = await AppLocalizations.delegate.load(Locale(code));
      for (final role in UserRole.values) {
        expect(role.localizedLabel(l10n), isNotEmpty, reason: '$code/${role.name}');
      }
    }
  });

  testWidgets('picking a language re-renders strings and persists the choice', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [savedLanguageCodeProvider.overrideWithValue('uz')],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(localeProvider),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Builder(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(context.l10n.settingsTitle)),
                body: const LanguageOptionsList(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sozlamalar'), findsOneWidget);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('bsmart.locale'), 'en');
  });
}
