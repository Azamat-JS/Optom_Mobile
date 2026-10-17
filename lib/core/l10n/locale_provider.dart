import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/app_l10n.dart';
import 'package:bsmart/core/l10n/locale_storage.dart';

/// Interface languages, in picker order. Uzbek is the default (the app's
/// original copy); see `l10n.yaml` / `lib/l10n/*.arb`.
const supportedLanguageCodes = ['uz', 'ru', 'en'];
const defaultLanguageCode = 'uz';

/// Native names — shown untranslated so a user can always find their own
/// language whatever the UI is currently in.
const languageNames = {'uz': "O'zbekcha", 'ru': 'Русский', 'en': 'English'};

/// The saved choice, read once in `bootstrap()` before `runApp` so the first
/// frame is already in the right language (overridden in the ProviderScope).
final savedLanguageCodeProvider = Provider<String?>((ref) => null);

/// Uzbek unless the user picked another language — the device language is
/// deliberately ignored (Uzbek is the product's default).
String resolveInitialLanguage(String? saved) {
  if (saved != null && supportedLanguageCodes.contains(saved)) return saved;
  return defaultLanguageCode;
}

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final code = resolveInitialLanguage(ref.read(savedLanguageCodeProvider));
    setActiveLanguageCode(code);
    return Locale(code);
  }

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode) || languageCode == state.languageCode) return;
    setActiveLanguageCode(languageCode);
    state = Locale(languageCode);
    await LocaleStorage().save(languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
