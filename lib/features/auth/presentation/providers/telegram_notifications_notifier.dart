import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_notification_settings.dart';
import 'package:bsmart/features/auth/domain/usecases/telegram_verification_usecases.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

/// The Profil switch for delivery messages from the verify bot (Phase 7 N3). Re-reads when the
/// signed-in user or their verification changes (verifying through the bot links the chat).
class TelegramNotificationsNotifier extends AutoDisposeAsyncNotifier<TelegramNotificationSettings> {
  @override
  Future<TelegramNotificationSettings> build() async {
    ref.watch(sessionNotifierProvider.select((s) => (s.valueOrNull?.user?.id, s.valueOrNull?.user?.phoneVerified)));
    final result = await getIt<TelegramNotificationsUseCase>().call();
    return result.fold((s) => s, (failure) => throw failure);
  }

  /// Optimistic; returns the failure (for a SnackBar) or null.
  Future<ApiException?> setEnabled(bool enabled) async {
    final previous = state.valueOrNull;
    if (previous != null) {
      state = AsyncData(TelegramNotificationSettings(linked: previous.linked, enabled: enabled, botUrl: previous.botUrl));
    }
    final result = await getIt<TelegramNotificationsUseCase>().call(enabled: enabled);
    return result.fold(
      (s) {
        state = AsyncData(s);
        return null;
      },
      (failure) {
        if (previous != null) state = AsyncData(previous);
        return failure;
      },
    );
  }
}

final telegramNotificationsProvider =
    AsyncNotifierProvider.autoDispose<TelegramNotificationsNotifier, TelegramNotificationSettings>(
  TelegramNotificationsNotifier.new,
);
