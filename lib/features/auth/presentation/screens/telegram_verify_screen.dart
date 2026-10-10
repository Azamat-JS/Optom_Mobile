import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/providers/telegram_verify_notifier.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/shared/widgets/language_picker.dart';

/// "Telegram orqali davom etish" wait screen — one flow for both register and
/// login. Starts a verification for [phone], opens the verify bot in Telegram,
/// then waits (polling) until the user shares their contact there.
///
/// Login/sign-up mode never navigates on its own after success:
/// [TelegramVerifyNotifier] adopts the session and `app_router.dart` moves the
/// user off this (auth-screen) route, exactly like a password login.
///
/// [verifyCurrentAccount] mode (V5, `/customer/verify-phone`): a logged-in
/// CUSTOMER confirms their *own* number to unlock phone-matched features. The
/// backend answers with a fresh session for the same account (now
/// `phoneVerified`); no auth redirect happens for an already logged-in user,
/// so this mode pops back itself.
class TelegramVerifyScreen extends ConsumerStatefulWidget {
  const TelegramVerifyScreen({required this.phone, this.verifyCurrentAccount = false, super.key});

  final String phone;
  final bool verifyCurrentAccount;

  @override
  ConsumerState<TelegramVerifyScreen> createState() => _TelegramVerifyScreenState();
}

class _TelegramVerifyScreenState extends ConsumerState<TelegramVerifyScreen> with WidgetsBindingObserver {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Re-renders the countdown.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from Telegram — check right away instead of waiting for the next tick.
    if (state == AppLifecycleState.resumed) ref.read(telegramVerifyProvider.notifier).pollNow();
  }

  Future<void> _start() async {
    final verification = await ref.read(telegramVerifyProvider.notifier).start(widget.phone);
    if (verification != null) await _openTelegram(verification.botUrl);
  }

  Future<void> _openTelegram(String botUrl) async {
    final opened = await launchUrl(Uri.parse(botUrl), mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.tgOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(telegramVerifyProvider, (previous, next) {
      if (next.phase == TelegramVerifyPhase.done && previous?.phase != TelegramVerifyPhase.done) {
        final l10n = context.l10n;
        final message = widget.verifyCurrentAccount
            ? l10n.tgPhoneVerified
            : (next.isNewUser ? l10n.tgWelcomeNew : l10n.tgWelcome);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        if (widget.verifyCurrentAccount) Navigator.of(context).maybePop();
      }
    });

    final state = ref.watch(telegramVerifyProvider);
    final l10n = context.l10n;
    final backLabel = widget.verifyCurrentAccount ? l10n.commonCancel : l10n.tgChangePhone;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tgTitle),
        // Part of sign-up/login for a new user — keep the language switch reachable.
        actions: [if (!widget.verifyCurrentAccount) const LanguagePickerButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: AppMotion.standard,
            child: KeyedSubtree(
              key: ValueKey(state.phase),
              child: switch (state.phase) {
                TelegramVerifyPhase.starting || TelegramVerifyPhase.done => _Busy(
                    label: state.phase != TelegramVerifyPhase.done
                        ? l10n.tgPreparing
                        : (widget.verifyCurrentAccount ? l10n.tgVerified : l10n.tgVerifiedLoggingIn),
                  ),
                TelegramVerifyPhase.waiting => _Waiting(
                    phone: widget.phone,
                    remaining: state.verification!.expiresAt.difference(DateTime.now()),
                    onOpenTelegram: () => _openTelegram(state.verification!.botUrl),
                    onChangePhone: () => Navigator.of(context).maybePop(),
                    backLabel: backLabel,
                    finishStep: widget.verifyCurrentAccount ? l10n.tgFinishStepVerify : l10n.tgFinishStepLogin,
                  ),
                TelegramVerifyPhase.mismatch => _Problem(
                    icon: Icons.phonelink_erase_outlined,
                    title: l10n.tgMismatchTitle,
                    message: widget.verifyCurrentAccount
                        ? l10n.tgMismatchOwn(widget.phone)
                        : l10n.tgMismatch(widget.phone),
                    onRetry: _start,
                    backLabel: backLabel,
                  ),
                TelegramVerifyPhase.expired => _Problem(
                    icon: Icons.timer_off_outlined,
                    title: l10n.tgExpiredTitle,
                    message: l10n.tgExpiredMessage,
                    onRetry: _start,
                    backLabel: backLabel,
                  ),
                TelegramVerifyPhase.failed => _Problem(
                    icon: Icons.error_outline,
                    title: l10n.tgFailedTitle,
                    message: state.errorMessage ?? l10n.commonUnknownError,
                    onRetry: _start,
                    backLabel: backLabel,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({
    required this.phone,
    required this.remaining,
    required this.onOpenTelegram,
    required this.onChangePhone,
    required this.backLabel,
    required this.finishStep,
  });

  final String phone;
  final Duration remaining;
  final VoidCallback onOpenTelegram;
  final VoidCallback onChangePhone;
  final String backLabel;
  final String finishStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final left = remaining.isNegative ? Duration.zero : remaining;
    final countdown = '${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}';
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.telegram, size: 72, color: theme.colorScheme.primary)
            .animate()
            .scale(begin: const Offset(0.8, 0.8), duration: AppMotion.slow, curve: AppMotion.emphasized),
        const SizedBox(height: 16),
        Text(
          l10n.tgConfirmInTelegram,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(phone, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        _Step(number: 1, text: l10n.tgStep1),
        _Step(number: 2, text: l10n.tgStep2),
        _Step(number: 3, text: l10n.tgStep3),
        _Step(number: 4, text: finishStep),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text(l10n.tgWaiting(countdown), style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onOpenTelegram,
          icon: const Icon(Icons.telegram),
          label: Text(l10n.tgOpenTelegram),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onChangePhone, child: Text(backLabel)),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: scheme.primaryContainer,
            child: Text('$number', style: TextStyle(fontSize: 13, color: scheme.onPrimaryContainer)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.backLabel,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        Icon(icon, size: 64, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: Text(context.l10n.commonRetry),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(backLabel),
        ),
      ],
    );
  }
}
