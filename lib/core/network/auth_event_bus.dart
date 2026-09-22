import 'dart:async';

/// Lets [RefreshInterceptor] (plain Dart, below the domain layer) signal a
/// forced logout without depending on `features/auth`'s domain/Riverpod
/// layers — [SessionNotifier] subscribes to [onForceLogout] instead.
class AuthEventBus {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onForceLogout => _controller.stream;

  void emitForceLogout() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
