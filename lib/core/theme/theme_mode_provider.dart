import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the chosen light/dark look (`system`/`light`/`dark`) — not sensitive, so plain
/// SharedPreferences like the language ([LocaleStorage]).
class ThemeModeStorage {
  static const _key = 'bsmart.themeMode';

  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_key);

  Future<void> save(ThemeMode mode) async => (await SharedPreferences.getInstance()).setString(_key, mode.name);
}

/// Settings order: follow the phone (the default), light, dark.
const themeModeChoices = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];

/// The saved choice by name; anything unknown or missing follows the phone.
ThemeMode parseThemeMode(String? saved) =>
    ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);

/// The saved choice, read once in `bootstrap()` before `runApp` so the first frame already has the
/// right look (overridden in the ProviderScope).
final savedThemeModeProvider = Provider<String?>((ref) => null);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => parseThemeMode(ref.read(savedThemeModeProvider));

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    state = mode;
    await ThemeModeStorage().save(mode);
  }
}

/// Every screen reads its brightness from `Theme.of(context)` (incl. `BrandTheme.of`), so this one
/// value at the `MaterialApp` switches the whole app.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
