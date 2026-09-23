import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/network/auth_event_bus.dart';
import 'package:bsmart/core/storage/active_store_storage.dart';
import 'package:bsmart/features/auth/domain/entities/session.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';
import 'package:bsmart/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/login_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/logout_usecase.dart';

/// The authenticated app's whole auth state: `null`/`null` means logged out.
class AuthState {
  const AuthState({this.session, this.user});

  final Session? session;
  final User? user;

  bool get isAuthenticated => session != null;

  static const loggedOut = AuthState();
}

/// Hand-written (not `@riverpod` code-gen — see `analysis_options.yaml`'s
/// note on why `riverpod_generator` is disabled for now). Behaves
/// identically to the generated form; only the provider declaration syntax
/// differs.
///
/// Must survive route changes — go_router's redirect logic reads it on
/// every navigation via [appRouterProvider]'s `refreshListenable`.
class SessionNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final eventBus = getIt<AuthEventBus>();
    final subscription = eventBus.onForceLogout.listen((_) => _clearState());
    ref.onDispose(subscription.cancel);

    final session = await getIt<AuthRepository>().restoreSession();
    if (session == null) return AuthState.loggedOut;

    final result = await getIt<GetCurrentUserUseCase>().call();
    return result.fold(
      (user) => AuthState(session: session, user: user),
      // Token present but rejected by the server (expired/revoked) — treat
      // as logged out rather than surfacing an error on the splash screen.
      (failure) => AuthState.loggedOut,
    );
  }

  Future<void> login({required String phone, required String password}) async {
    state = const AsyncLoading();
    final result = await getIt<LoginUseCase>().call(phone: phone, password: password);
    state = result.fold(
      (authResult) => AsyncData(AuthState(session: authResult.session, user: authResult.user)),
      (failure) => AsyncError(failure, StackTrace.current),
    );
  }

  Future<void> logout() async {
    await getIt<LogoutUseCase>().call();
    _clearState();
  }

  void _clearState() {
    // A stale active-store selection from a previous account would otherwise
    // survive into the next login and get sent as `X-Store-Id` for a store
    // that account doesn't own — the backend correctly 403s that, but the
    // failure is confusing without this context. Fire-and-forget: nothing in
    // this synchronous method awaits it, matching how little state clearing
    // elsewhere in this app needs to block on I/O.
    getIt<ActiveStoreStorage>().clear();
    state = const AsyncData(AuthState.loggedOut);
  }
}

final sessionNotifierProvider = AsyncNotifierProvider<SessionNotifier, AuthState>(
  SessionNotifier.new,
);
