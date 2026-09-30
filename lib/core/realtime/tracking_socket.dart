import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:bsmart/core/config/env.dart';
import 'package:bsmart/core/storage/active_store_storage.dart';
import 'package:bsmart/core/storage/secure_token_storage.dart';

enum TrackingSocketState { disconnected, connecting, connected, authFailed }

/// A server → client event on the tracking socket (`location`, `presence`,
/// and later `delivery:*`).
class TrackingSocketEvent {
  const TrackingSocketEvent(this.name, this.data);

  final String name;
  final Map<String, dynamic> data;
}

/// The app's one connection to the backend's `/tracking` Socket.IO namespace
/// (contract: Optom_Savdo CLAUDE.md "Tracking socket contract").
///
/// Plain Dart, owned by get_it like the Dio instances. Connection is
/// explicit: nothing connects until a feature calls [connect].
///
/// Auth: the handshake reads the *current* access token on every (re)connect.
/// If the server rejects it as `invalid_token` (expired), one authenticated
/// REST call through [_mainDio] lets the existing `RefreshInterceptor` do its
/// single-flight refresh, then the socket retries once — so token refresh
/// logic lives in exactly one place.
class TrackingSocket {
  TrackingSocket({
    required SecureTokenStorage tokenStorage,
    required ActiveStoreStorage activeStoreStorage,
    required Dio mainDio,
  })  : _tokenStorage = tokenStorage,
        _activeStoreStorage = activeStoreStorage,
        _mainDio = mainDio;

  final SecureTokenStorage _tokenStorage;
  final ActiveStoreStorage _activeStoreStorage;
  final Dio _mainDio;
  final _log = Logger();

  io.Socket? _socket;
  bool _refreshAttempted = false;

  final _stateController = StreamController<TrackingSocketState>.broadcast();
  final _eventsController = StreamController<TrackingSocketEvent>.broadcast();
  TrackingSocketState _state = TrackingSocketState.disconnected;

  TrackingSocketState get state => _state;
  Stream<TrackingSocketState> get states => _stateController.stream;
  Stream<TrackingSocketEvent> get events => _eventsController.stream;
  bool get isConnected => _state == TrackingSocketState.connected;

  void _setState(TrackingSocketState next) {
    if (_state == next) return;
    _state = next;
    if (!_stateController.isClosed) _stateController.add(next);
  }

  void connect() {
    final existing = _socket;
    if (existing != null) {
      if (!existing.connected) existing.connect();
      return;
    }
    _setState(TrackingSocketState.connecting);
    final socket = io.io(
      Env.trackingSocketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .setAuthFn((callback) async {
            final token = await _tokenStorage.readAccessToken();
            final storeId = await _activeStoreStorage.read();
            callback({'token': token ?? '', 'storeId': ?storeId});
          })
          .build(),
    );

    // `ready` (not `connect`) is the server's "authenticated" signal.
    socket.on('ready', (_) {
      _refreshAttempted = false;
      _setState(TrackingSocketState.connected);
    });
    socket.on('auth_error', (data) => _onAuthError(data));
    socket.onDisconnect((reason) {
      // A server-side disconnect (auth failure) isn't auto-retried by
      // socket.io; _onAuthError decides. Anything else reconnects on its own.
      if (reason != 'io server disconnect' && _state != TrackingSocketState.disconnected) {
        _setState(TrackingSocketState.connecting);
      }
    });
    socket.onAny((event, data) {
      if (data is Map && event != 'ready' && event != 'auth_error' && !_eventsController.isClosed) {
        _eventsController.add(TrackingSocketEvent(event, Map<String, dynamic>.from(data)));
      }
    });

    _socket = socket;
    socket.connect();
  }

  Future<void> _onAuthError(dynamic data) async {
    final code = data is Map ? data['code'] : null;
    _log.w('Tracking socket auth_error: $code');
    if (code == 'invalid_token' && !_refreshAttempted) {
      _refreshAttempted = true;
      try {
        await _mainDio.get<dynamic>('/auth/me'); // lets RefreshInterceptor refresh
        _socket?.connect();
        return;
      } on DioException {
        // Refresh failed — RefreshInterceptor already forced a logout.
      }
    }
    _setState(TrackingSocketState.authFailed);
  }

  /// Emits [event] and waits for the server's ack. Returns null when not
  /// connected or on timeout — callers treat that like "try again later".
  Future<Map<String, dynamic>?> request(
    String event, [
    Map<String, dynamic> data = const {},
    Duration timeout = const Duration(seconds: 5),
  ]) async {
    final socket = _socket;
    if (socket == null || !isConnected) return null;
    final completer = Completer<Map<String, dynamic>?>();
    socket.emitWithAck(event, data, ack: (dynamic response) {
      if (!completer.isCompleted) {
        completer.complete(response is Map ? Map<String, dynamic>.from(response) : null);
      }
    });
    return completer.future.timeout(timeout, onTimeout: () => null);
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _refreshAttempted = false;
    _setState(TrackingSocketState.disconnected);
  }
}
