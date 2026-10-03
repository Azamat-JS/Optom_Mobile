import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_motion.dart';

/// Customer self-registration (Phase 6) — phone only; the number is confirmed
/// through the Telegram verify bot ([RouteNames.telegramVerify]) and the new
/// `CUSTOMER` account takes its name from the Telegram profile. Same flow as
/// the login screen's "Telegram orqali davom etish": a number that already
/// has an account is simply logged in. Sign-up creates `CUSTOMER` accounts
/// only; SELLER/RETAILER stay SUPER_ADMIN-provisioned.
///
/// Password sign-up was removed from the app: it could not prove the number
/// belongs to the user, which in-app delivery tracking by phone (V5) relies on.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = FormGroup({
    'phone': FormControl<String>(
      value: '+998',
      validators: [Validators.required, Validators.pattern(r'^\+998\d{9}$')],
    ),
  });

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
    context.push(RouteNames.telegramVerifyFor(_form.control('phone').value as String));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: AppMotion.slow).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Yangi mijoz hisobi yaratish',
                  style: theme.textTheme.bodyMedium,
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
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Raqamingiz Telegram orqali tasdiqlanadi. Ism-familiyangiz Telegram profilingizdan olinadi — '
                  "keyin profilda o'zgartirishingiz mumkin.",
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.telegram),
                  label: const Text("Telegram orqali ro'yxatdan o'tish"),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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
