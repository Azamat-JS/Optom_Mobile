import 'package:shared_preferences/shared_preferences.dart';

/// Remembers that the courier accepted the location-sharing disclosure, so
/// it's shown once before the first OS permission prompt (Google Play's
/// "prominent disclosure" rule) and afterwards only on demand.
class TrackingDisclosureStorage {
  static const _key = 'tracking_disclosure_accepted_v1';

  Future<bool> isAccepted() async => (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  Future<void> accept() async => (await SharedPreferences.getInstance()).setBool(_key, true);
}
