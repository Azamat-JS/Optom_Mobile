import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

/// Login for SELLER/RETAILER (+ their `_ADMIN` staff) — the only Phase 1
/// roles. There is deliberately no "Register" link here: self-registration
/// (`POST /auth/register`) always creates a `CUSTOMER` account server-side
/// (see `auth.service.ts`), so operator accounts are provisioned by
/// SUPER_ADMIN, not self-service. Customer self-registration is Phase 2.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = FormGroup({
    'phone': FormControl<String>(
      value: '+998',
      validators: [Validators.required, Validators.pattern(r'^\+998\d{9}$')],
    ),
    'password': FormControl<String>(validators: [Validators.required, Validators.minLength(6)]),
  });

  bool _obscurePassword = true;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
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

    return Scaffold(
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: AppMotion.slow).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Optom Savdo tizimiga kirish',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: AppMotion.fast, duration: AppMotion.slow),
                  const SizedBox(height: 32),
                  ReactiveTextField<String>(
                    formControlName: 'phone',
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon raqam',
                      hintText: '+998901234567',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Telefon raqam kiritilishi shart',
                      ValidationMessage.pattern: (_) => 'Format: +998XXXXXXXXX',
                    },
                  ).animate().fadeIn(delay: AppMotion.standard),
                  const SizedBox(height: 16),
                  ReactiveTextField<String>(
                    formControlName: 'password',
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Parol',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validationMessages: {
                      ValidationMessage.required: (_) => 'Parol kiritilishi shart',
                      ValidationMessage.minLength: (_) => 'Kamida 6 ta belgi',
                    },
                    onSubmitted: (_) => _submit(),
                  ).animate().fadeIn(delay: AppMotion.standard + AppMotion.fast),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Kirish'),
                  ).animate().fadeIn(delay: AppMotion.slow),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
