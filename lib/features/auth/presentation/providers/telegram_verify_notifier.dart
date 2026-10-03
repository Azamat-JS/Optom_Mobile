import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_verification.dart';
import 'package:bsmart/features/auth/domain/usecases/telegram_verification_usecases.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

enum TelegramVerifyPhase {
  /// `POST /auth/telegram/start` in flight.
  starting,

  /// Waiting for the user to share their contact in the bot; polling.
  waiting,

  /// Telegram's number differs from the typed one — needs a fresh start.
  mismatch,

  /// The 10-minute window passed.
  expired,

  /// Start failed, or the request was already used elsewhere.
  failed,

  /// Session adopted — go_router's redirect takes it from here.
  done,
}

class TelegramVerifyState {
  const TelegramVerifyState({
    required this.phase,
    required this.phone,
    this.verification,
    this.errorMessage,
    this.isNewUser = false,
  });

  final TelegramVerifyPhase phase;
  final String phone;
  final TelegramVerification? verification;
  final String? errorMessage;
  final bool isNewUser;

  TelegramVerifyState copyWith({
    TelegramVerifyPhase? phase,
    TelegramVerification? verification,
    String? errorMessage,
    bool? isNewUser,
  }) {
    return TelegramVerifyState(
      phase: phase ?? this.phase,
      phone: phone,
      verification: verification ?? this.verification,
      errorMessage: errorMessage,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

/// Drives one "Telegram orqali davom etish" attempt: starts the verification,
/// then polls every [_pollInterval] until the backend reports a terminal
/// status. The screen calls [pollNow] when the app returns to the foreground
/// (the user is coming back from Telegram), so the usual case finishes
/// without waiting for the next tick.
///
/// Auto-disposed with the wait screen, which cancels the timer — leaving the
/// screen abandons the attempt (the backend lets it expire on its own).
class TelegramVerifyNotifier extends AutoDisposeNotifier<TelegramVerifyState> {
  /// `/auth/telegram/poll` is throttled at 60/min per IP; 3 s keeps several
  /// devices behind one carrier NAT comfortably under it.
  static const _pollInterval = Duration(seconds: 3);

  Timer? _timer;
  bool _pollInFlight = false;
  bool _disposed = false;

  @override
  TelegramVerifyState build() {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    return const TelegramVerifyState(phase: TelegramVerifyPhase.starting, phone: '');
  }

  /// Starts (or restarts, after a mismatch/expiry) verification of [phone].
  /// Returns the started request so the screen can open Telegram right away.
  Future<TelegramVerification?> start(String phone) async {
    _timer?.cancel();
    state = TelegramVerifyState(phase: TelegramVerifyPhase.starting, phone: phone);
    final result = await getIt<StartTelegramVerificationUseCase>().call(phone);
    if (_disposed) return null;
    return result.fold(
      (verification) {
        state = state.copyWith(phase: TelegramVerifyPhase.waiting, verification: verification);
        _timer = Timer.periodic(_pollInterval, (_) => pollNow());
        return verification;
      },
      (failure) {
        state = state.copyWith(phase: TelegramVerifyPhase.failed, errorMessage: failure.message);
        return null;
      },
    );
  }

  Future<void> pollNow() async {
    final verification = state.verification;
    if (state.phase != TelegramVerifyPhase.waiting || verification == null || _pollInFlight) return;
    _pollInFlight = true;
    try {
      final result = await getIt<PollTelegramVerificationUseCase>().call(verification);
      // The attempt may have been restarted or abandoned while this poll was in flight.
      if (_disposed || state.verification != verification) return;
      result.fold(
        (status) => _apply(status),
        (failure) {
          // Network blips are transient — keep polling. 404 means the request
          // is gone server-side (purged), so it can never finish.
          if (failure is NotFoundApiException) {
            _finish(TelegramVerifyPhase.failed, "So'rov topilmadi. Qaytadan boshlang.");
          }
        },
      );
    } finally {
      _pollInFlight = false;
    }
  }

  void _apply(TelegramVerificationStatus status) {
    switch (status) {
      case TelegramPending():
        if (DateTime.now().isAfter(state.verification!.expiresAt)) {
          _finish(TelegramVerifyPhase.expired);
        }
      case TelegramMismatch():
        _finish(TelegramVerifyPhase.mismatch);
      case TelegramExpired():
        _finish(TelegramVerifyPhase.expired);
      case TelegramConsumed():
        _finish(TelegramVerifyPhase.failed, "Bu so'rov allaqachon ishlatilgan. Qaytadan boshlang.");
      case TelegramVerified(:final authResult, :final isNewUser):
        _timer?.cancel();
        state = state.copyWith(phase: TelegramVerifyPhase.done, isNewUser: isNewUser);
        ref.read(sessionNotifierProvider.notifier).adoptAuthResult(authResult);
    }
  }

  void _finish(TelegramVerifyPhase phase, [String? message]) {
    _timer?.cancel();
    state = state.copyWith(phase: phase, errorMessage: message);
  }
}

final telegramVerifyProvider =
    NotifierProvider.autoDispose<TelegramVerifyNotifier, TelegramVerifyState>(TelegramVerifyNotifier.new);
