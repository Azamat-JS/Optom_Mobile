import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_sheet_header.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_theme.dart';
import 'package:bsmart/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:bsmart/core/l10n/l10n.dart';

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
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = PhoneNumberField.e164(_phone.text);
    if (phone == null) return;
    FocusScope.of(context).unfocus();
    context.push(RouteNames.telegramVerifyFor(phone));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      // Builder: read AuthColors/text styles from inside AuthScaffold's theme.
      child: Builder(builder: (context) => _form(context, l10n)),
    );
  }

  Widget _form(BuildContext context, AppLocalizations l10n) {
    final colors = AuthColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthSheetHeader(title: l10n.commonRegister, subtitle: l10n.registerSubtitle),
        const SizedBox(height: 24),
        PhoneNumberField(controller: _phone, onSubmitted: _submit),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: colors.accentText),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.registerHint, style: Theme.of(context).textTheme.bodySmall)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _phone,
          builder: (context, value, _) => FilledButton.icon(
            onPressed: PhoneNumberField.e164(value.text) == null ? null : _submit,
            icon: const Icon(Icons.telegram, size: 22),
            label: Text(l10n.registerWithTelegram),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: () => context.go(RouteNames.login), child: Text(l10n.registerHaveAccount)),
      ],
    );
  }
}
