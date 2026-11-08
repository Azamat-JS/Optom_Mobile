import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bsmart/core/theme/theme_mode_provider.dart';

void main() {
  test('a saved name maps back to its mode; anything else follows the phone', () {
    expect(parseThemeMode('light'), ThemeMode.light);
    expect(parseThemeMode('dark'), ThemeMode.dark);
    expect(parseThemeMode('system'), ThemeMode.system);
    expect(parseThemeMode(null), ThemeMode.system);
    expect(parseThemeMode('purple'), ThemeMode.system);
  });

  test('starts from the saved choice and persists a new one', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(overrides: [savedThemeModeProvider.overrideWithValue('dark')]);
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    await container.read(themeModeProvider.notifier).setMode(ThemeMode.light);
    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(await ThemeModeStorage().read(), 'light');
  });
}
