import 'dart:async';
import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' show Permission, PermissionActions, PermissionStatusGetters;

import 'package:bsmart/core/location/location_fix.dart';

enum LocationAccess { granted, denied, deniedForever, servicesDisabled }

/// Wraps geolocator (GPS stream + location permission) and the Android 13+
/// notification permission the tracking notification needs.
///
/// Background behaviour, deliberately with **"while in use" permission
/// only** (never "Allow all the time"): a stream started while the app is
/// visible keeps running in the background — on Android through geolocator's
/// location foreground service (persistent notification), on iOS through
/// `allowBackgroundLocationUpdates` with the system's blue location
/// indicator. Less invasive for couriers, and avoids Google Play's
/// background-location review.
class LocationTracker {
  Future<LocationAccess> ensureAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.servicesDisabled;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      _ => LocationAccess.denied,
    };
  }

  /// Android 13+ only: without it the foreground-service notification is
  /// hidden, which would break "the courier always sees they're tracked".
  /// Returns true when granted or not applicable.
  Future<bool> ensureNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// One-shot current position for map pickers ("Mening joylashuvim").
  /// Returns null if location is off/denied or no fix arrives in time.
  ///
  /// Android goes straight to the plain GPS provider (`forceLocationManager`):
  /// a one-shot request through Play Services' fused provider pops Google's
  /// "turn on Location Accuracy" dialog on *every* call when that setting is
  /// off — fine precision isn't worth that for dropping a map pin. A recent
  /// last-known fix is returned instantly.
  Future<LocationFix?> currentPosition() async {
    if (await ensureAccess() != LocationAccess.granted) return null;
    LocationFix fromPosition(Position p) =>
        LocationFix(lat: p.latitude, lng: p.longitude, accuracy: p.accuracy, timestamp: p.timestamp);
    try {
      if (Platform.isAndroid) {
        final last = await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);
        if (last != null && DateTime.now().difference(last.timestamp) < const Duration(minutes: 2)) {
          return fromPosition(last);
        }
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: Platform.isAndroid
            ? AndroidSettings(accuracy: LocationAccuracy.high, forceLocationManager: true)
            : const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 12));
      return fromPosition(p);
    } catch (_) {
      return null;
    }
  }

  Stream<ServiceStatus> get serviceStatusChanges => Geolocator.getServiceStatusStream();

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  /// GPS fix stream. On Android this also starts the foreground service with
  /// the given notification text; cancelling the subscription stops both.
  ///
  /// Android uses Play Services' fused provider first. If that reports the
  /// location service as disabled while location is actually on (happens
  /// when the phone's "Google Location Accuracy" setting is off — the
  /// network provider is then unavailable), it falls back to the plain GPS
  /// provider instead of blocking the courier.
  Stream<LocationFix> watch({required String notificationTitle, required String notificationText}) {
    late final StreamController<LocationFix> controller;
    StreamSubscription<LocationFix>? sub;

    void listen({required bool forceLocationManager}) {
      sub = _positions(notificationTitle, notificationText, forceLocationManager: forceLocationManager).listen(
        controller.add,
        onError: (Object error, StackTrace st) async {
          // (A stream error event — not a throw — so it must be caught here.)
          final canFallBack =
              error is LocationServiceDisabledException &&
              !forceLocationManager &&
              Platform.isAndroid &&
              await Geolocator.isLocationServiceEnabled();
          if (!canFallBack) return controller.addError(error, st);
          await sub?.cancel();
          listen(forceLocationManager: true);
        },
      );
    }

    controller = StreamController<LocationFix>(
      onListen: () => listen(forceLocationManager: false),
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  Stream<LocationFix> _positions(
    String notificationTitle,
    String notificationText, {
    required bool forceLocationManager,
  }) {
    final LocationSettings settings;
    if (Platform.isAndroid) {
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        forceLocationManager: forceLocationManager,
        intervalDuration: const Duration(seconds: 2),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notificationTitle,
          notificationText: notificationText,
          notificationChannelName: 'Joylashuvni ulashish',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else if (Platform.isIOS) {
      settings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      settings = const LocationSettings(accuracy: LocationAccuracy.high);
    }
    return Geolocator.getPositionStream(locationSettings: settings).map(
      (p) => LocationFix(
        lat: p.latitude,
        lng: p.longitude,
        accuracy: p.accuracy,
        speed: p.speed >= 0 ? p.speed : null,
        heading: p.heading >= 0 ? p.heading : null,
        timestamp: p.timestamp,
      ),
    );
  }
}
