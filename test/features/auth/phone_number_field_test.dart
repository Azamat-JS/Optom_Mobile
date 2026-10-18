import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/features/auth/presentation/widgets/auth_theme.dart';
import 'package:bsmart/features/auth/presentation/widgets/phone_number_field.dart';

Future<TextEditingController> _pumpField(WidgetTester tester) async {
  final controller = TextEditingController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('uz'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AuthTheme.build(Brightness.light),
      home: Scaffold(body: PhoneNumberField(controller: controller)),
    ),
  );
  return controller;
}

void main() {
  group('PhoneNumberField.e164', () {
    test('needs exactly 9 local digits', () {
      expect(PhoneNumberField.e164('90 123 45 67'), '+998901234567');
      expect(PhoneNumberField.e164('90 123 45 6'), isNull);
      expect(PhoneNumberField.e164(''), isNull);
    });
  });

  test('formatUzPhone groups the local part', () {
    expect(formatUzPhone('+998901234567'), '+998 90 123 45 67');
    expect(formatUzPhone('901234567'), '+998 90 123 45 67');
    expect(formatUzPhone('123'), '123');
  });

  testWidgets('typing groups the digits and caps them at 9', (tester) async {
    final controller = await _pumpField(tester);
    await tester.enterText(find.byType(TextField), '9012345678999');
    expect(controller.text, '90 123 45 67');
  });

  testWidgets('a pasted full number keeps only the local part', (tester) async {
    final controller = await _pumpField(tester);
    await tester.enterText(find.byType(TextField), '+998 (90) 123-45-67');
    expect(controller.text, '90 123 45 67');
    expect(PhoneNumberField.e164(controller.text), '+998901234567');
  });

  testWidgets('backspace over a group space removes the digit before it', (tester) async {
    final controller = await _pumpField(tester);
    await tester.enterText(find.byType(TextField), '90123');
    expect(controller.text, '90 123');
    // Delete the trailing digit, then the space that now ends the text.
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: '90 12', selection: TextSelection.collapsed(offset: 5)),
    );
    await tester.pump();
    expect(controller.text, '90 12');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: '90 1', selection: TextSelection.collapsed(offset: 4)),
    );
    await tester.pump();
    expect(controller.text, '90 1');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: '90 ', selection: TextSelection.collapsed(offset: 3)),
    );
    await tester.pump();
    expect(controller.text, '90');
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(text: '9', selection: TextSelection.collapsed(offset: 1)),
    );
    await tester.pump();
    expect(controller.text, '9');
  });

  testWidgets('clear button appears with text and empties the field', (tester) async {
    final controller = await _pumpField(tester);
    expect(find.byTooltip('Tozalash'), findsNothing);
    await tester.enterText(find.byType(TextField), '901');
    await tester.pump();
    await tester.tap(find.byTooltip('Tozalash'));
    await tester.pump();
    expect(controller.text, isEmpty);
  });
}
