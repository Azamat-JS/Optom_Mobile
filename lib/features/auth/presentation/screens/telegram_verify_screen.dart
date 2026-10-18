import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/providers/telegram_verify_notifier.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_sheet_header.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:bsmart/core/l10n/l10n.dart';

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
    void back() => Navigator.of(context).maybePop();

    return AuthScaffold(
      // Part of sign-up/login for a new user — keep the language switch reachable.
      showLanguage: !widget.verifyCurrentAccount,
      showSkip: false,
      child: AnimatedSwitcher(
        duration: AppMotion.standard,
        child: KeyedSubtree(
          key: ValueKey(state.phase),
          child: switch (state.phase) {
            TelegramVerifyPhase.starting => _Busy(label: l10n.tgPreparing),
            TelegramVerifyPhase.done => _Done(
              label: widget.verifyCurrentAccount ? l10n.tgVerified : l10n.tgVerifiedLoggingIn,
            ),
            TelegramVerifyPhase.waiting => _Waiting(
              phone: widget.phone,
              remaining: state.verification!.expiresAt.difference(DateTime.now()),
              onOpenTelegram: () => _openTelegram(state.verification!.botUrl),
              onChangePhone: back,
              backLabel: backLabel,
              finishStep: widget.verifyCurrentAccount ? l10n.tgFinishStepVerify : l10n.tgFinishStepLogin,
            ),
            TelegramVerifyPhase.mismatch => _Problem(
              icon: Icons.phonelink_erase_rounded,
              title: l10n.tgMismatchTitle,
              message: widget.verifyCurrentAccount ? l10n.tgMismatchOwn(widget.phone) : l10n.tgMismatch(widget.phone),
              onRetry: _start,
              onBack: back,
              backLabel: backLabel,
            ),
            TelegramVerifyPhase.expired => _Problem(
              icon: Icons.timer_off_rounded,
              title: l10n.tgExpiredTitle,
              message: l10n.tgExpiredMessage,
              onRetry: _start,
              onBack: back,
              backLabel: backLabel,
            ),
            TelegramVerifyPhase.failed => _Problem(
              icon: Icons.error_outline_rounded,
              title: l10n.tgFailedTitle,
              message: state.errorMessage ?? l10n.commonUnknownError,
              onRetry: _start,
              onBack: back,
              backLabel: backLabel,
            ),
          },
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
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          const SizedBox(width: double.infinity),
          const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3)),
          const SizedBox(height: 20),
          Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          const SizedBox(width: double.infinity),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: colors.successTint, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, size: 44, color: colors.success),
          ).animate().scale(begin: const Offset(0.6, 0.6), duration: AppMotion.slow, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
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
    final colors = BrandColors.of(context);
    final left = remaining.isNegative ? Duration.zero : remaining;
    final countdown = '${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}';
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthSheetHeader(title: l10n.tgConfirmInTelegram),
        const SizedBox(height: 4),
        // "Sent to <phone> ✎" from the reference.
        Row(
          children: [
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${l10n.tgVerifyingNumber}: '),
                    TextSpan(
                      text: formatUzPhone(phone),
                      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: backLabel,
              onPressed: onChangePhone,
              icon: Icon(Icons.edit_square, size: 20, color: colors.accentText),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _Step(number: 1, text: l10n.tgStep1),
              _Step(number: 2, text: l10n.tgStep2),
              _Step(number: 3, text: l10n.tgStep3),
              _Step(number: 4, text: finishStep, last: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _StatusPill(text: l10n.tgWaiting(countdown)),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onOpenTelegram,
          icon: const Icon(Icons.telegram, size: 22),
          label: Text(l10n.tgOpenTelegram),
        ),
        const SizedBox(height: 4),
        TextButton(onPressed: onChangePhone, child: Text(backLabel)),
      ],
    );
  }
}

/// Numbered step with a connector line down to the next one.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text, this.last = false});

  final int number;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
                child: Text(
                  '$number',
                  style: const TextStyle(color: AppColors.onBrand, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 3), color: colors.outline),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3, bottom: last ? 0 : 14),
              child: Text(
                text,
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Green "in progress" pill, fading out to the right like the reference's
/// "We are validating the OTP".
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 28, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: [colors.successTint, colors.successTint.withValues(alpha: 0)],
            stops: const [0.6, 1],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2.2, color: colors.success)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: colors.success,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
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
    required this.onBack,
    required this.backLabel,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = BrandColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: colors.errorTint, shape: BoxShape.circle),
            child: Icon(icon, size: 36, color: theme.colorScheme.error),
          ).animate().scale(begin: const Offset(0.8, 0.8), duration: AppMotion.slow, curve: AppMotion.emphasized),
        ),
        const SizedBox(height: 18),
        Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(onPressed: onRetry, child: Text(context.l10n.commonRetry)),
        const SizedBox(height: 4),
        TextButton(onPressed: onBack, child: Text(backLabel)),
      ],
    );
  }
}
