import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_theme.dart';

/// Uzbek mobile number input: a fixed "🇺🇿 +998" prefix and the 9 local
/// digits typed into [controller], shown grouped as "90 123 45 67".
///
/// Pasting a full "+998 90 123 45 67" keeps only the local part. Read the
/// value with [PhoneNumberField.e164].
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    required this.controller,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  final bool autofocus;
  final bool enabled;

  static const localDigits = 9;

  /// "+998XXXXXXXXX" once all 9 digits are typed, else null.
  static String? e164(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return digits.length == localDigits ? '+998$digits' : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);
    final l10n = context.l10n;
    return TextField(
      controller: controller,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [_UzPhoneFormatter()],
      onSubmitted: (_) => onSubmitted?.call(),
      style: TextStyle(
        fontFamily: AuthTheme.fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: l10n.authPhoneLabel,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: '90 123 45 67',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇺🇿', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '+998',
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 1.2, height: 24, color: colors.outline),
            ],
          ),
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty || !enabled
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: l10n.authClear,
                  onPressed: controller.clear,
                  icon: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(color: colors.textMuted.withValues(alpha: 0.35), shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded, size: 14, color: colors.sheet),
                  ),
                ),
        ),
      ),
    );
  }
}

/// "+998 90 123 45 67" from a "+998XXXXXXXXX" (or legacy) number; returns
/// the input unchanged when it doesn't have 9+ digits.
String formatUzPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 9) return phone;
  return '+998 ${_group(digits.substring(digits.length - 9))}';
}

String _group(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i == 2 || i == 5 || i == 7) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

class _UzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Backspace over a group space: delete the digit before it instead.
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    if (newValue.text.length < oldValue.text.length && digits == oldDigits && digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    // A pasted/autofilled full number: drop the country code.
    if (digits.length > PhoneNumberField.localDigits && digits.startsWith('998')) digits = digits.substring(3);
    if (digits.length > PhoneNumberField.localDigits) digits = digits.substring(0, PhoneNumberField.localDigits);
    final text = _group(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
