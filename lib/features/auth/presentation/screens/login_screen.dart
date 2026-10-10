import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/shared/widgets/language_picker.dart';

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
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = FormGroup({
    'phone': FormControl<String>(value: '+998', validators: [Validators.required, Validators.pattern(r'^\+998\d{9}$')]),
    'password': FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
  });

  bool _obscurePassword = true;
  bool _showPassword = false;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _continueWithTelegram() {
    final phone = _form.control('phone');
    if (phone.invalid) {
      phone.markAsTouched();
      return;
    }
    context.push(RouteNames.telegramVerifyFor(phone.value as String));
  }

  void _submit() {
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }
    final phone = _form.control('phone').value as String;
    final password = _form.control('password').value as String;
    ref.read(sessionNotifierProvider.notifier).login(phone: phone, password: password);
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

    return Scaffold(
      // Language is picked right here: a signed-out user can't reach Settings.
      appBar: AppBar(actions: const [LanguagePickerButton()]),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ReactiveForm(
              formGroup: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'bsmart',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: AppMotion.slow).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: AppMotion.fast, duration: AppMotion.slow),
                  const SizedBox(height: 32),
                  ReactiveTextField<String>(
                    formControlName: 'phone',
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.authPhoneLabel,
                      hintText: '+998901234567',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validationMessages: {
                      ValidationMessage.required: (_) => l10n.authPhoneRequired,
                      ValidationMessage.pattern: (_) => l10n.authPhoneFormat,
                    },
                  ).animate().fadeIn(delay: AppMotion.standard),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: isLoading ? null : _continueWithTelegram,
                    icon: const Icon(Icons.telegram),
                    label: Text(l10n.loginContinueWithTelegram),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ).animate().fadeIn(delay: AppMotion.standard + AppMotion.fast),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginAccountAutoCreated,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (!_showPassword)
                    TextButton(
                      onPressed: () => setState(() => _showPassword = true),
                      child: Text(l10n.loginWithPassword),
                    )
                  else
                    ..._passwordFields(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _passwordFields(bool isLoading) {
    final l10n = context.l10n;
    return [
      ReactiveTextField<String>(
        formControlName: 'password',
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: l10n.loginPasswordLabel,
          prefixIcon: const Icon(Icons.lock_outline),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validationMessages: {
          ValidationMessage.required: (_) => l10n.loginPasswordRequired,
          ValidationMessage.minLength: (_) => l10n.loginPasswordMinLength,
        },
        onSubmitted: (_) => _submit(),
      ).animate().fadeIn(duration: AppMotion.standard),
      const SizedBox(height: 16),
      OutlinedButton(
        onPressed: isLoading ? null : _submit,
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(l10n.commonLogin),
      ).animate().fadeIn(duration: AppMotion.standard),
    ];
  }
}
