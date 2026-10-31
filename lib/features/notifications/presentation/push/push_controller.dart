import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/app_l10n.dart';
import 'package:bsmart/core/l10n/locale_provider.dart';
import 'package:bsmart/core/router/app_router.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:bsmart/features/notifications/domain/usecases/register_push_device_usecase.dart';
import 'package:bsmart/features/notifications/domain/usecases/remove_push_device_usecase.dart';
import 'package:bsmart/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:bsmart/features/notifications/presentation/push/push_target.dart';

/// The app's root ScaffoldMessenger, so a push that arrives while the app is open can show a
/// SnackBar from outside any screen.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Push notifications (Optom_Savdo "CRM" → C7). **Android only for now**: iPhone push needs an
/// Apple Developer account (APNs key), so on iOS Firebase is never started and the in-app bell
/// works as before.
///
/// - Signed in → asks for notification permission (Android 13+), then registers this phone's FCM
///   token with the server in the interface language. Again on token refresh and language change.
/// - Logout → [unregister] removes the token on the server (while still authenticated) and deletes
///   it on the phone; a forced logout only deletes it (the server drops it on the next send).
/// - Push while open → the bell's count refreshes and a SnackBar offers to open it. Tapped push →
///   marks it read and opens the driver or the inbox.
class PushController {
  PushController(this._ref);

  final Ref _ref;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  bool _started = false;
  bool _registered = false;

  static bool get supported => !kIsWeb && Platform.isAndroid;

  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
  }

  Future<void> onUserChanged(String? userId) async {
    if (userId == null) {
      if (_registered) {
        _registered = false;
        await _deleteToken();
      }
      return;
    }
    if (!await _start()) return;
    await _register();
  }

  Future<void> onLocaleChanged() async {
    if (_registered) await _register();
  }

  /// Called by logout before the session's tokens are cleared.
  Future<void> unregister() async {
    if (!_started || !_registered) return;
    _registered = false;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await getIt<RemovePushDeviceUseCase>().call(token).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint('Push: unregister failed: $e');
    }
    await _deleteToken();
  }

  Future<bool> _start() async {
    if (!supported) return false;
    if (_started) return true;
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Push: Firebase failed to start: $e');
      return false;
    }
    _started = true;
    _subscriptions
      ..add(FirebaseMessaging.instance.onTokenRefresh.listen((_) => _register()))
      ..add(FirebaseMessaging.onMessage.listen(_onForeground))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen(_open));
    // The app was started by tapping a push.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _open(initial);
    return true;
  }

  Future<void> _register() async {
    if (_ref.read(currentUserIdProvider) == null) return;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      final result = await getIt<RegisterPushDeviceUseCase>().call(
        token: token,
        platform: 'ANDROID',
        locale: _ref.read(localeProvider).languageCode,
      );
      result.fold((_) => _registered = true, (f) => debugPrint('Push: register failed: ${f.message}'));
    } catch (e) {
      // No Google Play services, no network… The inbox still works; the next start retries.
      debugPrint('Push: register failed: $e');
    }
  }

  Future<void> _deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Push: deleteToken failed: $e');
    }
  }

  void _onForeground(RemoteMessage message) {
    // Android shows nothing for a push while the app is open; refresh the bell and say so here.
    _ref.read(unreadNotificationsProvider.notifier).refresh();
    final title = message.notification?.title;
    if (title == null) return;
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: appL10n.notifOpen, onPressed: () => _open(message)),
      ),
    );
  }

  void _open(RemoteMessage message) {
    final id = message.data['notificationId'];
    if (id is String && id.isNotEmpty) {
      getIt<MarkNotificationReadUseCase>().call(id).then((_) => _ref.read(unreadNotificationsProvider.notifier).refresh());
    }
    final role = _ref.read(sessionNotifierProvider).valueOrNull?.session?.role;
    final route = pushTargetRoute(message.data, role);
    // On a cold start the router is still leaving the splash screen; push once it has settled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (_ref.read(currentUserIdProvider) == null) return;
        _ref.read(appRouterProvider).push(route);
      });
    });
  }
}

PushController? _current;

/// For logout. Not through Riverpod: the controller watches the session, so the session notifier
/// reading [pushControllerProvider] would be a provider cycle (CircularDependencyError).
Future<void> unregisterPushDevice() => _current?.unregister() ?? Future<void>.value();

/// Watched by the app root so it lives for the whole session.
final pushControllerProvider = Provider<PushController>((ref) {
  final controller = PushController(ref);
  _current = controller;
  ref.onDispose(() {
    controller.dispose();
    if (identical(_current, controller)) _current = null;
  });
  ref.listen(currentUserIdProvider, (_, userId) => controller.onUserChanged(userId), fireImmediately: true);
  ref.listen(localeProvider, (_, _) => controller.onLocaleChanged());
  return controller;
});
