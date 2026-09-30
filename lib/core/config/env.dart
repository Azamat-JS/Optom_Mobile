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

  /// Socket.IO URL of the live-tracking namespace. Defaults to the API
  /// server's origin (API_BASE_URL minus its `/api` path) + `/tracking`;
  /// `SOCKET_URL` in `.env` overrides it if the socket is ever served from a
  /// different host. See Optom_Savdo CLAUDE.md "Tracking socket contract".
  static String get trackingSocketUrl {
    final override = dotenv.env['SOCKET_URL'];
    if (override != null && override.isNotEmpty) return override;
    final api = Uri.parse(apiBaseUrl);
    return '${api.origin}/tracking';
  }
}
