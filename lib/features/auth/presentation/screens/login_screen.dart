import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_sheet_header.dart';
import 'package:bsmart/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:bsmart/core/l10n/l10n.dart';

/// One login screen for every role — SELLER/RETAILER (+ their `_ADMIN`
/// staff) and `CUSTOMER`s alike (the storefront's guest flow lands here
/// whenever signing in is required — see `app_router.dart`'s redirect).
///
/// The primary action is "Telegram orqali davom etish" (Phase 6): the phone
/// is confirmed by sharing the user's own Telegram contact with the verify
/// bot — an existing account (any role) is logged in, an unknown number gets
/// a new `CUSTOMER` account. Phone + password stays as an optional fallback
/// behind "Parol bilan kirish"; SELLER/RETAILER accounts are still only
/// provisioned by SUPER_ADMIN, never self-service.
///
/// Buttons stay disabled (grey) until the input is complete, instead of
/// showing validation errors.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _minPasswordLength = 6;

  final _phone = TextEditingController();
  final _password = TextEditingController();
  late final _inputs = Listenable.merge([_phone, _password]);

  bool _obscurePassword = true;
  bool _showPassword = false;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  String? get _e164 => PhoneNumberField.e164(_phone.text);

  bool get _canLoginWithPassword => _e164 != null && _password.text.length >= _minPasswordLength;

  void _continueWithTelegram() {
    final phone = _e164;
    if (phone == null) return;
    FocusScope.of(context).unfocus();
    context.push(RouteNames.telegramVerifyFor(phone));
  }

  void _submitPassword() {
    if (!_canLoginWithPassword) return;
    FocusScope.of(context).unfocus();
    ref.read(sessionNotifierProvider.notifier).login(phone: _e164!, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionNotifierProvider, (previous, next) {
      final error = next.error;
      if (error is ApiException) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      }
    });

    final isLoading = ref.watch(sessionNotifierProvider).isLoading;
    final l10n = context.l10n;

    return AuthScaffold(
      // `context` below is inside AuthScaffold's theme.
      child: ListenableBuilder(
        listenable: _inputs,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthSheetHeader(title: l10n.authEnterNumber, subtitle: l10n.loginSubtitle),
            const SizedBox(height: 24),
            PhoneNumberField(
              controller: _phone,
              enabled: !isLoading,
              onSubmitted: _showPassword ? null : _continueWithTelegram,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isLoading || _e164 == null ? null : _continueWithTelegram,
              icon: const Icon(Icons.telegram, size: 22),
              label: Text(l10n.loginContinueWithTelegram),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.loginAccountAutoCreated,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: AppMotion.standard,
              child: _showPassword
                  ? _passwordSection(isLoading)
                  : Column(
                      key: const ValueKey('password-collapsed'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthOrDivider(label: l10n.authOr),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: isLoading ? null : () => setState(() => _showPassword = true),
                          icon: const Icon(Icons.lock_outline_rounded, size: 20),
                          label: Text(l10n.loginWithPassword),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordSection(bool isLoading) {
    final l10n = context.l10n;
    return Column(
      key: const ValueKey('password-open'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _password,
          enabled: !isLoading,
          obscureText: _obscurePassword,
          autofocus: true,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitPassword(),
          decoration: InputDecoration(
            labelText: l10n.loginPasswordLabel,
            helperText: l10n.loginPasswordMinLength,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: isLoading || !_canLoginWithPassword ? null : _submitPassword,
          child: isLoading
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
              : Text(l10n.commonLogin),
        ),
      ],
    ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.1, end: 0);
  }
}
