import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads runtime config loaded from `.env` by `bootstrap.dart`.
///
/// Phase 1 uses a single `.env` file for simplicity. Migrate to Flutter
/// flavors + `--dart-define-from-file` once multiple environments (e.g. a
/// staging Optom_Savdo deployment) need distinct API base URLs — see the
/// bsmart implementation plan, section 1.
abstract final class Env {
  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value == null || value.isEmpty) {
      throw StateError('API_BASE_URL is not set in .env — copy .env.example to .env first.');
    }
    return value;
  }
}
