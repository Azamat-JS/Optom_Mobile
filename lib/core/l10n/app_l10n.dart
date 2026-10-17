import 'dart:ui';

import 'package:bsmart/core/l10n/locale_provider.dart';
import 'package:bsmart/l10n/app_localizations.dart';

String _activeLanguageCode = defaultLanguageCode;

/// Called by [LocaleNotifier] whenever the interface language changes, before
/// the new locale is published, so the next frame already reads the new copy.
void setActiveLanguageCode(String code) => _activeLanguageCode = code;

/// Strings for code that has no `BuildContext` — enum `label` getters,
/// [ApiException] fallbacks, [CurrencyFormatter]. Widgets should keep using
/// `context.l10n`; both follow the same active locale.
AppLocalizations get appL10n => lookupAppLocalizations(Locale(_activeLanguageCode));
