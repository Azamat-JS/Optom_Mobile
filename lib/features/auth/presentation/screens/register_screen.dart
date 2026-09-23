import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

/// Customer self-registration — `POST /auth/register` always creates a
/// `CUSTOMER` account server-side (see `auth.service.ts`), so this screen is
/// only ever reachable from the storefront side of the app, never from the
/// operator `LoginScreen`.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = FormGroup({
    'firstName': FormControl<String>(validators: [Validators.required]),
    'lastName': FormControl<String>(validators: [Validators.required]),
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
    ref.read(sessionNotifierProvider.notifier).register(
          firstName: _form.control('firstName').value as String,
          lastName: _form.control('lastName').value as String,
          phone: _form.control('phone').value as String,
          password: _form.control('password').value as String,
        );
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
      appBar: AppBar(title: const Text("Ro'yxatdan o'tish")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ReactiveForm(
            formGroup: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'bsmart',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: AppMotion.slow).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Yangi mijoz hisobi yaratish',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: AppMotion.fast, duration: AppMotion.slow),
                const SizedBox(height: 32),
                ReactiveTextField<String>(
                  formControlName: 'firstName',
                  decoration: const InputDecoration(labelText: 'Ism', border: OutlineInputBorder()),
                  validationMessages: {ValidationMessage.required: (_) => 'Ismni kiriting'},
                ),
                const SizedBox(height: 16),
                ReactiveTextField<String>(
                  formControlName: 'lastName',
                  decoration: const InputDecoration(labelText: 'Familiya', border: OutlineInputBorder()),
                  validationMessages: {ValidationMessage.required: (_) => 'Familiyani kiriting'},
                ),
                const SizedBox(height: 16),
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
                ),
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
                ),
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
                      : const Text("Ro'yxatdan o'tish"),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: const Text('Hisobingiz bormi? Kirish'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
