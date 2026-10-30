// TEMPORARY (CRM C6 on-device check) — delete after the run. Needs the local backend on :4005 and
// Optom_Savdo scratch seed `c6-seed.js seed`. `--dart-define=C6_LOCALE=ru` runs a read-only pass in
// Russian for layout.
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/bootstrap.dart';
import 'package:bsmart/core/config/env.dart';
import 'package:bsmart/core/l10n/locale_storage.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';

const _locale = String.fromEnvironment('C6_LOCALE', defaultValue: 'uz');
const _owner = '+998990001212';
const _password = 'Test12345!';

Future<void> _until(WidgetTester tester, Finder finder, {int seconds = 20, String? why}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for ${why ?? finder}');
}

Future<void> _hold(WidgetTester tester, [int ms = 2500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _back(WidgetTester tester) async {
  GoRouter.of(tester.element(find.byType(Scaffold).last)).pop();
  await _hold(tester, 800);
}

void _check(String name, bool ok) {
  // ignore: avoid_print
  print('${ok ? 'PASS' : 'FAIL'} $name');
  expect(ok, isTrue, reason: name);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CRM + inbox on device ($_locale)', (tester) async {
    await dotenv.load(fileName: '.env');
    final login = await Dio(BaseOptions(baseUrl: Env.apiBaseUrl))
        .post<Map<String, dynamic>>('/auth/login', data: {'phone': _owner, 'password': _password});
    const storage = FlutterSecureStorage();
    await storage.write(key: 'bsmart.access_token', value: login.data!['accessToken'] as String);
    await storage.write(key: 'bsmart.refresh_token', value: login.data!['refreshToken'] as String);
    await LocaleStorage().save(_locale);
    await bootstrap();

    final ru = _locale == 'ru';
    final drivers = ru ? 'Водители' : 'Haydovchilar';
    final reminders = ru ? 'Напоминания' : 'Eslatmalar';

    // --- home: CRM tiles and the bell with 2 unread
    await _until(tester, find.text(drivers), why: 'CRM tile on home');
    _check('home shows the CRM tiles', find.text(reminders).evaluate().isNotEmpty);
    await _until(tester, find.descendant(of: find.byType(Badge), matching: find.text('2')), why: 'bell badge 2');
    _check('bell shows 2 unread', true);
    await _hold(tester);

    // --- inbox
    await _tap(tester, find.byIcon(Icons.notifications_rounded));
    await _until(tester, find.textContaining('01 A 123 BC'), why: 'inbox rows');
    _check(
      'inbox: staff reminders with the driver note',
      find.textContaining('Jasur Karimov').evaluate().isNotEmpty &&
          find.textContaining('+998990100001').evaluate().isNotEmpty &&
          find.textContaining('01 B 222 CC').evaluate().isNotEmpty,
    );
    await _hold(tester);
    if (!ru) {
      await _tap(tester, find.textContaining('01 A 123 BC'));
      await _until(tester, find.text('Xizmatlar tarixi'), why: 'driver page from notification');
      _check('opening a staff notification opens the driver', find.text('Jasur Karimov').evaluate().isNotEmpty);
      await _back(tester);
      await _back(tester);
      await _until(tester, find.descendant(of: find.byType(Badge), matching: find.text('1')), why: 'bell badge 1');
      _check('…and marks it read (badge 1)', true);
    } else {
      await _back(tester);
    }

    // --- drivers list
    await _tap(tester, find.text(drivers).first);
    await _until(tester, find.text('Bobur Aliyev'), why: 'drivers list');
    _check('list shows both drivers with plates', find.textContaining('01 A 123 BC').evaluate().isNotEmpty);
    await _hold(tester);
    if (!ru) {
      await tester.enterText(find.byType(TextField).first, '01 b');
      await _until(tester, find.text('Bobur Aliyev'), why: 'search result');
      await _hold(tester, 1500);
      _check('search by plate leaves Bobur only', find.text('Jasur Karimov').evaluate().isEmpty);
      await tester.enterText(find.byType(TextField).first, '');
      await _until(tester, find.text('Jasur Karimov'), why: 'list after clearing search');
    }

    // --- driver page
    await _tap(tester, find.text('Jasur Karimov'));
    await _until(tester, find.textContaining('Antifriz'), why: 'driver detail history');
    _check(
      'driver page: car, daily km, next due, history',
      find.text('01 A 123 BC').evaluate().isNotEmpty &&
          find.text(ru ? '~120 км в день' : 'Kuniga ~120 km').evaluate().isNotEmpty &&
          find.textContaining(ru ? 'Следующее: Antifriz' : 'Keyingi: Antifriz').evaluate().isNotEmpty,
    );
    _check(
      'store without a bot: says so',
      find.textContaining(ru ? 'не подключён Telegram-бот' : "Telegram bot ulanmagan").evaluate().isNotEmpty,
    );
    await _hold(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await _hold(tester);

    // --- visit form
    await _tap(tester, find.text(ru ? 'Записать обслуживание' : 'Xizmat yozish').first);
    await _until(tester, find.text(ru ? 'Добавить товар' : "Mahsulot qo'shish"), why: 'visit form');
    await _hold(tester);
    if (!ru) {
      await _tap(tester, find.textContaining('Xizmatni saqlash'));
      await _until(tester, find.text("Kamida bitta qator qo'shing"), why: 'empty visit refused');
      _check('saving without lines is refused', true);
      await _tap(tester, find.text("Qo'lda"));
      await _tap(tester, find.textContaining('Xizmatni saqlash'));
      await _until(tester, find.text("Qo'lda qo'shilgan qator nomini kiriting"), why: 'manual line without name refused');
      _check('a manual line without a name is refused', true);
      await _tap(tester, find.byTooltip("O'chirish").first);
      await _tap(tester, find.text("Mahsulot qo'shish"));
      await _until(tester, find.text('Moy 5W-30 Lukoil'), why: 'product sheet');
      await _hold(tester, 1500);
      await _tap(tester, find.text('Moy 5W-30 Lukoil'));
      await _until(tester, find.textContaining('Omborda'), why: 'product line');
      await tester.enterText(find.widgetWithText(TextField, 'Keyingi xizmatgacha, km'), '5000');
      await tester.pump(const Duration(milliseconds: 300));
      final expected = DateFormat('dd.MM.yyyy').format(crmToday().add(const Duration(days: 42)));
      _check('due date preview 5000 km at 120/day', find.text('Taxminan $expected da qaytib keladi').evaluate().isNotEmpty);
      await _hold(tester);
      await _tap(tester, find.textContaining('Xizmatni saqlash'));
      await _until(tester, find.text('Xizmat yozildi'), why: 'visit saved');
      await _until(tester, find.textContaining('Moy 5W-30 Lukoil ×'), why: 'new visit in history');
      _check('saved visit appears in the history', true);
      await _hold(tester);
      await _back(tester);
    } else {
      await _back(tester);
      await _back(tester);
    }
    await _back(tester);

    // --- reminders
    await _until(tester, find.text(reminders), why: 'home again');
    await _tap(tester, find.text(reminders).first);
    await _until(tester, find.textContaining('Antifriz'), why: 'reminders list');
    _check(
      'reminders: overdue and soon tabs carry counts',
      find.text(ru ? 'Просрочено · 1' : "Muddati o'tgan · 1").evaluate().isNotEmpty &&
          find.text(ru ? '7 дней · 1' : '7 kun ichida · 1').evaluate().isNotEmpty,
    );
    await _hold(tester);
    if (!ru) {
      await _tap(tester, find.byIcon(Icons.more_horiz_rounded).first);
      await _until(tester, find.text('Bajarildi'), why: 'reminder menu');
      await _tap(tester, find.text('Bajarildi').last);
      await _until(tester, find.text('Bajarildi deb belgilandi'), why: 'done toast');
      await _hold(tester, 1500);
      _check('done reminder leaves the list', find.textContaining('Antifriz').evaluate().isEmpty);
      await _back(tester);

      // --- create a driver from the list
      await _tap(tester, find.text(drivers).first);
      await _until(tester, find.byType(FloatingActionButton), why: 'drivers list FAB');
      await _tap(tester, find.byType(FloatingActionButton));
      await _until(tester, find.text('Yangi haydovchi'), why: 'driver form');
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Sanjar');
      await tester.enterText(fields.at(2), '+998990100003');
      await tester.enterText(fields.at(3), '10 123 abc');
      await tester.enterText(fields.at(4), 'Damas');
      await _hold(tester, 800);
      await _tap(tester, find.text('Saqlash'));
      await _until(tester, find.text('10 123 ABC'), why: 'new driver page');
      _check('new driver lands on their page with the car', find.text('Sanjar').evaluate().isNotEmpty);
      await _hold(tester);
    }
  });
}
