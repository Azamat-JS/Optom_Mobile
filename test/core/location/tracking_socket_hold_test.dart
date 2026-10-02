import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/realtime/tracking_socket.dart';
import 'package:bsmart/core/storage/active_store_storage.dart';
import 'package:bsmart/core/storage/secure_token_storage.dart';

/// The socket is reference-counted: it must stay up while *anyone* holds it.
class _Spy extends TrackingSocket {
  _Spy() : super(tokenStorage: SecureTokenStorage(), activeStoreStorage: ActiveStoreStorage(), mainDio: Dio());

  int connects = 0;
  int disconnects = 0;

  @override
  void connect() => connects++;

  @override
  void disconnect() => disconnects++;
}

void main() {
  test('stays connected until the last holder releases', () {
    final s = _Spy();
    final courier = Object(), screen = Object();
    s.hold(courier);
    s.hold(screen);
    s.release(screen);
    expect(s.disconnects, 0, reason: 'courier still holds it');
    s.release(courier);
    expect(s.disconnects, 1);
  });

  test('releasing an unknown or already-released holder is a no-op', () {
    final s = _Spy();
    final a = Object();
    s.release(a);
    s.hold(a);
    s.release(a);
    s.release(a);
    expect(s.disconnects, 1);
  });
}
