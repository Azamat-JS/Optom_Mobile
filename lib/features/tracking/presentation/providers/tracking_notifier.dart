import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'
    show Geolocator, LocationServiceDisabledException, PermissionDeniedException, ServiceStatus;
import 'package:logger/logger.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/location/location_fix.dart';
import 'package:bsmart/core/location/location_outbox.dart';
import 'package:bsmart/core/location/location_tracker.dart';
import 'package:bsmart/core/realtime/tracking_socket.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_state.dart';

/// Drives the courier's live location sharing: GPS stream → send policy →
/// tracking socket, plus session start/resume/stop, heartbeats and the
/// status the UI shows.
///
/// Tracking never starts on its own: only [goOnline] (an explicit courier
/// action, after the disclosure) starts it. It stops on [goOffline] and on
/// logout.
class TrackingNotifier extends Notifier<TrackingState> {
  static const _heartbeatEvery = Duration(seconds: 20);
  static const _noFixAfter = Duration(seconds: 45);

  final _log = Logger();

  TrackingSocket get _socket => getIt<TrackingSocket>();
  LocationTracker get _tracker => getIt<LocationTracker>();
  LocationOutbox get _outbox => getIt<LocationOutbox>();

  StreamSubscription<LocationFix>? _fixes;
  StreamSubscription<TrackingSocketState>? _socketStates;
  StreamSubscription<ServiceStatus>? _serviceStatus;
  Timer? _heartbeat;

  final _fixesController = StreamController<LocationFix>.broadcast();
  LocationFix? _lastFix;
  DateTime? _lastFixAt;
  bool _sessionActive = false;
  bool _startedOnce = false;
  bool _sending = false;
  bool _flushing = false;

  /// Last fix that entered the pipeline (sent or queued) — what the send policy compares against.
  LocationFix? _lastPiped;

  @override
  TrackingState build() {
    ref.listen(sessionNotifierProvider, (_, next) {
      if (next.valueOrNull?.isAuthenticated == true) return;
      // Logged out: stop sharing and forget everything tied to the previous account.
      final reset = state.isOnline ? goOffline() : Future<void>.value();
      reset.then((_) => state = const TrackingState());
    });
    ref.onDispose(() {
      _teardown();
      _fixesController.close();
    });
    return const TrackingState();
  }

  Future<void> goOnline() async {
    if (state.isOnline) return;
    state = state.copyWith(phase: TrackingPhase.starting);

    final access = await _tracker.ensureAccess();
    if (access != LocationAccess.granted) {
      state = TrackingState(
        phase: switch (access) {
          LocationAccess.servicesDisabled => TrackingPhase.servicesDisabled,
          LocationAccess.deniedForever => TrackingPhase.permissionDeniedForever,
          _ => TrackingPhase.permissionDenied,
        },
      );
      return;
    }
    final notificationsOk = await _tracker.ensureNotificationPermission();
    state = state.copyWith(notificationsDenied: !notificationsOk);

    _startedOnce = false;
    _sessionActive = false;
    _lastPiped = null;
    _lastFixAt = DateTime.now();

    _socketStates = _socket.states.listen(_onSocketState);
    _socket.hold(this);
    if (_socket.isConnected) unawaited(_startSession());

    _startFixes();
    _serviceStatus = _tracker.serviceStatusChanges.listen((s) async {
      // Re-check: some devices emit transient provider changes.
      if (s == ServiceStatus.disabled && !await Geolocator.isLocationServiceEnabled()) {
        _stopWith(TrackingPhase.servicesDisabled);
      }
    });
    _heartbeat = Timer.periodic(_heartbeatEvery, (_) => _tick());
  }

  /// Every GPS fix while online (before the send policy) — for the courier's own map marker.
  Stream<LocationFix> get fixes => _fixesController.stream;

  /// The most recent GPS fix, if online.
  LocationFix? get lastFix => _lastFix;

  /// Called by the deliveries feature whenever the courier's set of accepted, unfinished
  /// deliveries changes. Restarts the GPS stream (cheap) so the persistent notification names the
  /// delivery — the courier always sees *why* they're being tracked.
  void setActiveDelivery(String? label, {bool customerWatches = false}) {
    if (label == state.activeDeliveryLabel && customerWatches == state.customerWatches) return;
    state = state.withActiveDelivery(label, customerWatches: customerWatches);
    if (_fixes != null) {
      _fixes?.cancel();
      _startFixes();
    }
  }

  void _startFixes() {
    final label = state.activeDeliveryLabel;
    _fixes = _tracker
        .watch(
          notificationTitle: 'bsmart joylashuvingizni ulashmoqda',
          notificationText: label != null
              ? (state.customerWatches
                  ? "Faol yetkazish: $label — mijoz va biznes egangiz ko'radi"
                  : "Faol yetkazish: $label — biznes egangiz ko'radi")
              : "Onlayn — joylashuvingiz biznes egasiga ko'rinadi",
        )
        .listen(_onFix, onError: _onGpsError);
  }

  Future<void> goOffline() async {
    final wasSession = _sessionActive;
    _teardown();
    // The courier stopped sharing: nothing from before may be sent later (consent).
    _outbox.clear();
    _lastFix = null;
    state = TrackingState(
      notificationsDenied: state.notificationsDenied,
      activeDeliveryLabel: state.activeDeliveryLabel,
      customerWatches: state.customerWatches,
    );
    if (wasSession) await _socket.request('tracking:stop');
    _socket.release(this);
  }

  void _onGpsError(Object error) {
    _log.w('GPS stream error: $error');
    if (error is LocationServiceDisabledException) {
      _stopWith(TrackingPhase.servicesDisabled);
    } else if (error is PermissionDeniedException) {
      _stopWith(TrackingPhase.permissionDenied);
    } else if (state.isOnline) {
      // Unknown platform hiccup: stay online, the UI shows "no GPS signal".
      state = state.copyWith(phase: TrackingPhase.noGpsFix);
    }
  }

  /// Location became unusable while online (GPS switched off, permission
  /// revoked): stop streaming and show the matching fix-it banner.
  Future<void> _stopWith(TrackingPhase phase) async {
    await goOffline();
    state = state.copyWith(phase: phase);
  }

  void _onSocketState(TrackingSocketState s) {
    switch (s) {
      case TrackingSocketState.connected:
        unawaited(_startSession());
      case TrackingSocketState.connecting:
        _sessionActive = false;
        if (state.isOnline) state = state.copyWith(phase: TrackingPhase.reconnecting);
      case TrackingSocketState.authFailed:
        unawaited(goOffline());
      case TrackingSocketState.disconnected:
        break;
    }
  }

  // First connect after going online opens a fresh session; any later
  // (re)connect resumes it, so a network blip doesn't split the session.
  Future<void> _startSession() async {
    final ack = await _socket.request('tracking:start', {'resume': _startedOnce});
    if (ack?['ok'] != true) return;
    _startedOnce = true;
    _sessionActive = true;
    if (state.phase == TrackingPhase.starting || state.phase == TrackingPhase.reconnecting) {
      state = state.copyWith(phase: TrackingPhase.noGpsFix);
    }
    unawaited(_flush());
  }

  /// Phase 7 N5: sends the offline backlog oldest-first, one acked `location:batch` at a time,
  /// until it's empty or the connection drops again. Live sends wait while it's non-empty so the
  /// server sees every point in order.
  Future<void> _flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      while (_sessionActive && state.isOnline && _outbox.isNotEmpty) {
        final batch = _outbox.nextBatch();
        final ack = await _socket.request(
          'location:batch',
          {'points': batch.map((f) => f.toJson()).toList()},
          const Duration(seconds: 15),
        );
        if (ack == null) return; // no connection — try again on the next (re)connect
        if (ack['ok'] == true) {
          // Rejected points were bad data (too old, jump) — dropped server-side, same as live.
          _outbox.removeFirst(batch.length);
          if (ack['live'] == true) {
            state = state.copyWith(phase: TrackingPhase.sharing, lastSentAt: DateTime.now());
          }
        } else if (ack['reason'] == 'no_session') {
          _sessionActive = false;
          unawaited(_startSession());
          return;
        } else if (ack['reason'] != 'rate_limited') {
          _outbox.removeFirst(batch.length); // can never succeed (malformed) — don't loop on it
        }
        // Shares the server's per-subject rate limit with live points (one message / 500 ms).
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    } finally {
      _flushing = false;
    }
  }

  Future<void> _onFix(LocationFix fix) async {
    _lastFixAt = DateTime.now();
    _lastFix = fix;
    if (!_fixesController.isClosed) _fixesController.add(fix);
    if (!state.isOnline || _sending) return;
    if (!LocationSendPolicy.shouldSend(lastSent: _lastPiped, fix: fix)) return;
    // No session (socket down / reconnecting) or a backlog still draining: queue it, in order.
    if (!_sessionActive || _outbox.isNotEmpty) {
      _outbox.add(fix);
      _lastPiped = fix;
      if (_sessionActive) unawaited(_flush());
      return;
    }
    _sending = true;
    _lastPiped = fix;
    try {
      final ack = await _socket.request('location', fix.toJson());
      if (!state.isOnline) return;
      if (ack == null) {
        _outbox.add(fix); // timed out / dropped mid-flight — keep it for the backlog
        return;
      }
      if (ack['accepted'] == true) {
        state = state.copyWith(phase: TrackingPhase.sharing, lastSentAt: DateTime.now());
      } else if (ack['reason'] == 'no_session') {
        _sessionActive = false;
        await _startSession();
      } else if (ack['reason'] != 'rate_limited') {
        // Rejected as bad data (inaccurate, stale, GPS jump) — keep going.
        state = state.copyWith(phase: TrackingPhase.noGpsFix);
      }
    } finally {
      _sending = false;
    }
  }

  // Keeps presence alive without a fresh fix and flags a lost GPS signal.
  void _tick() {
    if (!_sessionActive) return;
    final lastFix = _lastFixAt;
    if (lastFix != null && DateTime.now().difference(lastFix) > _noFixAfter) {
      state = state.copyWith(phase: TrackingPhase.noGpsFix);
    }
    final lastSentAt = state.lastSentAt;
    if (lastSentAt == null || DateTime.now().difference(lastSentAt) >= _heartbeatEvery) {
      unawaited(_socket.request('heartbeat'));
    }
  }

  void _teardown() {
    _fixes?.cancel();
    _socketStates?.cancel();
    _serviceStatus?.cancel();
    _heartbeat?.cancel();
    _fixes = null;
    _socketStates = null;
    _serviceStatus = null;
    _heartbeat = null;
    _sessionActive = false;
  }
}

final trackingNotifierProvider = NotifierProvider<TrackingNotifier, TrackingState>(TrackingNotifier.new);
