import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/network/auth_event_bus.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/auth/domain/entities/auth_result.dart';
import 'package:bsmart/features/auth/domain/entities/session.dart';
import 'package:bsmart/features/auth/domain/entities/telegram_verification.dart';
import 'package:bsmart/features/auth/domain/entities/user.dart';
import 'package:bsmart/features/auth/domain/repositories/auth_repository.dart';
import 'package:bsmart/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:bsmart/features/auth/domain/usecases/telegram_verification_usecases.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/providers/telegram_verify_notifier.dart';

const _session = Session(
  accessToken: 'a',
  refreshToken: 'r',
  userId: 'u1',
  role: UserRole.customer,
  canAccessPos: false,
);
const _user = User(
  id: 'u1',
  phone: '+998901234567',
  firstName: 'Ali',
  lastName: '',
  role: UserRole.customer,
  canAccessPos: false,
);

/// Only the Telegram calls matter here; everything else is unreachable.
class _FakeRepo implements AuthRepository {
  Result<TelegramVerification>? startResult;
  final polls = <Result<TelegramVerificationStatus>>[];
  int pollCount = 0;

  @override
  Future<Result<TelegramVerification>> startTelegramVerification(String phone) async => startResult!;

  @override
  Future<Result<TelegramVerificationStatus>> pollTelegramVerification(TelegramVerification v) async {
    pollCount++;
    return polls.removeAt(0);
  }

  @override
  Future<Session?> restoreSession() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

TelegramVerification _verification({Duration ttl = const Duration(minutes: 10)}) => TelegramVerification(
      verificationId: 'v1',
      clientSecret: 's',
      botUrl: 'https://t.me/bot?start=v_x',
      botUsername: 'bot',
      expiresAt: DateTime.now().add(ttl),
    );

void main() {
  late _FakeRepo repo;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repo = _FakeRepo();
    getIt
      ..registerSingleton<AuthRepository>(repo)
      ..registerSingleton(AuthEventBus())
      ..registerFactory(() => GetCurrentUserUseCase(getIt()))
      ..registerFactory(() => StartTelegramVerificationUseCase(getIt()))
      ..registerFactory(() => PollTelegramVerificationUseCase(getIt()));
    container = ProviderContainer();
    // Keep the auto-dispose provider alive for the whole test.
    container.listen(telegramVerifyProvider, (_, _) {});
    await container.read(sessionNotifierProvider.future);
  });

  tearDown(() => container.dispose());

  TelegramVerifyNotifier notifier() => container.read(telegramVerifyProvider.notifier);
  TelegramVerifyState state() => container.read(telegramVerifyProvider);

  test('start → waiting; a failed start surfaces the message', () async {
    repo.startResult = Result.ok(_verification());
    expect(await notifier().start('+998901234567'), isNotNull);
    expect(state().phase, TelegramVerifyPhase.waiting);

    repo.startResult = const Result.err(UnknownApiException("Bu raqam uchun urinishlar juda ko'p."));
    expect(await notifier().start('+998901234567'), isNull);
    expect(state().phase, TelegramVerifyPhase.failed);
    expect(state().errorMessage, contains("juda ko'p"));
  });

  test('pending keeps waiting and transient network errors do not end the attempt', () async {
    repo.startResult = Result.ok(_verification());
    await notifier().start('+998901234567');
    repo.polls.addAll([const Result.ok(TelegramPending()), const Result.err(NetworkApiException())]);
    await notifier().pollNow();
    await notifier().pollNow();
    expect(state().phase, TelegramVerifyPhase.waiting);
  });

  test('verified adopts the session exactly once and stops polling', () async {
    repo.startResult = Result.ok(_verification());
    await notifier().start('+998901234567');
    repo.polls.add(
      const Result.ok(TelegramVerified(AuthResult(session: _session, user: _user), isNewUser: true)),
    );
    await notifier().pollNow();
    expect(state().phase, TelegramVerifyPhase.done);
    expect(state().isNewUser, isTrue);
    expect(container.read(sessionNotifierProvider).valueOrNull?.user?.id, 'u1');

    await notifier().pollNow(); // terminal — must not hit the backend again
    expect(repo.pollCount, 1);
  });

  test('mismatch / expired / consumed / 404 are terminal', () async {
    final cases = <Result<TelegramVerificationStatus>, TelegramVerifyPhase>{
      const Result.ok(TelegramMismatch()): TelegramVerifyPhase.mismatch,
      const Result.ok(TelegramExpired()): TelegramVerifyPhase.expired,
      const Result.ok(TelegramConsumed()): TelegramVerifyPhase.failed,
      const Result.err(NotFoundApiException()): TelegramVerifyPhase.failed,
    };
    for (final MapEntry(key: answer, value: phase) in cases.entries) {
      repo.startResult = Result.ok(_verification());
      await notifier().start('+998901234567');
      repo.polls.add(answer);
      await notifier().pollNow();
      expect(state().phase, phase, reason: '$answer');
    }
  });

  test('a pending answer past expiresAt is treated as expired', () async {
    repo.startResult = Result.ok(_verification(ttl: const Duration(seconds: -1)));
    await notifier().start('+998901234567');
    repo.polls.add(const Result.ok(TelegramPending()));
    await notifier().pollNow();
    expect(state().phase, TelegramVerifyPhase.expired);
  });

  test('a restart ignores an answer that belongs to the previous attempt', () async {
    repo.startResult = Result.ok(_verification());
    await notifier().start('+998901234567');
    repo.polls.add(const Result.ok(TelegramMismatch()));
    final stalePoll = notifier().pollNow();
    await notifier().start('+998901234567'); // new attempt while the poll is in flight
    await stalePoll;
    expect(state().phase, TelegramVerifyPhase.waiting);
  });
}
