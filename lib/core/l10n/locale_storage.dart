import 'package:shared_preferences/shared_preferences.dart';

/// Persists the chosen interface language code (`uz`/`ru`/`en`) — not
/// sensitive, so plain SharedPreferences like [ActiveStoreStorage].
class LocaleStorage {
  static const _key = 'bsmart.locale';

  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_key);

  Future<void> save(String languageCode) async =>
      (await SharedPreferences.getInstance()).setString(_key, languageCode);
}
