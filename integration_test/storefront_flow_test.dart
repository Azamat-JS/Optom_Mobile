// TEMPORARY verification test (Phase 9 U2a/U2b) — drives the real app on a
// simulator against the local backend as a guest. Not part of the suite.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bsmart/bootstrap.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';

Future<void> pumpFor(WidgetTester t, [int ms = 1200]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> waitFor(WidgetTester t, Finder f, {int timeoutMs = 15000, String? why}) async {
  for (var waited = 0; waited < timeoutMs; waited += 100) {
    if (f.evaluate().isNotEmpty) return;
    await t.pump(const Duration(milliseconds: 100));
  }
  fail('Timed out waiting for ${why ?? f}');
}

/// Drags the main list by [step] until [f] has at least one match.
Future<void> scrollToFind(WidgetTester t, Finder f, {double step = -300, int maxDrags = 40}) async {
  for (var i = 0; i < maxDrags && f.evaluate().isEmpty; i++) {
    await t.drag(mainScroll.first, Offset(0, step));
    await pumpFor(t, 400);
  }
  if (f.evaluate().isEmpty) fail('Could not scroll to $f');
}

/// Taps the first match whose centre is clear of the top bar and bottom nav,
/// scrolling down until there is one.
Future<void> tapVisible(WidgetTester t, Finder f) async {
  final height = t.view.physicalSize.height / t.view.devicePixelRatio;
  for (var i = 0; i < 30; i++) {
    for (final element in f.evaluate()) {
      final box = element.renderObject! as RenderBox;
      final center = box.localToGlobal(box.size.center(Offset.zero));
      if (center.dy > 140 && center.dy < height - 170) {
        await t.tapAt(center);
        return;
      }
    }
    await t.drag(mainScroll.first, const Offset(0, -200));
    await pumpFor(t, 400);
  }
  fail('No tappable $f');
}

Finder get mainScroll => find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  description: 'vertical scrollable',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('storefront home + search, as a guest', (t) async {
    await bootstrap();
    await waitFor(t, find.text('Xush kelibsiz!'), why: 'guest home');
    final log = <String>[];
    void ok(String step) {
      log.add('OK $step');
      // ignore: avoid_print
      print('STEP OK: $step');
    }

    ok('home greeting');

    // --- Shop strip filter -------------------------------------------------
    await waitFor(t, find.text("Do'konlar"), why: 'shop strip');
    await t.tap(find.text('Osh markazi').first);
    await pumpFor(t, 3000); // filtered feed loads; the chip is below the fold
    await scrollToFind(t, find.byType(InputChip));
    ok('shop card → shop chip');
    await t.tap(find.byTooltip('Filtrni olib tashlash'));
    await pumpFor(t, 2500);
    expect(find.byType(InputChip), findsNothing);
    ok('shop chip removed');

    // --- Add to cart, stepper, badge -----------------------------------------
    await scrollToFind(t, find.text("QO'SHISH"));
    await tapVisible(t, find.text("QO'SHISH"));
    await pumpFor(t, 600);
    // ignore: avoid_print
    print('DEBUG stepper=${find.byIcon(Icons.remove_rounded).evaluate().length} '
        'snack=${find.byType(SnackBar).evaluate().length} '
        'texts=${find.byType(SnackBar).evaluate().isEmpty ? '' : t.widgetList<Text>(find.descendant(of: find.byType(SnackBar), matching: find.byType(Text))).map((w) => w.data).join('|')}');
    await waitFor(t, find.textContaining("savatga qo'shildi"), why: 'added snackbar');
    await waitFor(t, find.byIcon(Icons.remove_rounded), why: 'stepper');
    ok('ADD → snackbar + stepper');
    await tapVisible(t, find.byIcon(Icons.add_rounded));
    await pumpFor(t, 500);
    expect(find.text('2'), findsWidgets);
    ok('stepper + → 2');
    await tapVisible(t, find.byIcon(Icons.remove_rounded));
    await pumpFor(t, 300);
    await tapVisible(t, find.byIcon(Icons.remove_rounded));
    await pumpFor(t, 500);
    expect(find.byIcon(Icons.remove_rounded), findsNothing);
    ok('stepper − − → back to ADD');

    // --- Favourites segment as a guest ----------------------------------------
    await scrollToFind(t, find.text('SEVIMLILAR'), step: 400);
    await t.drag(mainScroll.first, const Offset(0, 300));
    await pumpFor(t, 600);
    await t.tap(find.text('SEVIMLILAR'));
    await waitFor(t, find.textContaining('hisobingizga kiring'), why: 'guest favourites prompt');
    ok('guest favourites → login prompt');
    await t.tap(find.text('YANGI KELGANLAR'));
    await pumpFor(t, 600);

    // --- Search: open, type, suggestions -------------------------------------
    await scrollToFind(t, find.textContaining('ni qidiring'), step: 400);
    await t.drag(mainScroll.first, const Offset(0, 2000));
    await pumpFor(t, 800);
    await t.tap(find.textContaining('ni qidiring'));
    await waitFor(t, find.text("Mahsulot va do'konlarni qidiring"), why: 'search screen');
    ok('hero search → search screen');
    await t.enterText(find.byType(TextField), 'soat');
    await waitFor(t, find.text("«soat» bo'yicha do'konlar"), why: 'shop suggestions');
    expect(find.text('Boshqa mos natijalar'), findsOneWidget);
    ok('typing → suggestions');

    // --- Submit, results, sort, chips, tabs ------------------------------------
    await t.testTextInput.receiveAction(TextInputAction.search);
    await waitFor(t, find.text('Natijalar: Barchasi'), why: 'results header');
    await waitFor(t, find.byType(SearchProductCard), why: 'result cards');
    expect(find.text('5 ta mos mahsulot'), findsWidgets);
    ok('submit → results (5)');

    double firstPrice() => t.widget<SearchProductCard>(find.byType(SearchProductCard).first).product.price;
    await t.tap(find.text('Saralash'));
    await waitFor(t, find.text('Avval arzonlari'), why: 'sort sheet');
    await t.tap(find.text('Avval arzonlari'));
    await pumpFor(t, 800);
    expect(firstPrice(), 10000);
    ok('sort cheap first → 10 000');
    await t.tap(find.text('Avval arzonlari'));
    await waitFor(t, find.text('Avval qimmatlari'), why: 'sort sheet again');
    await t.tap(find.text('Avval qimmatlari'));
    await pumpFor(t, 800);
    expect(firstPrice(), 334000);
    ok('sort expensive first → 334 000');

    await t.tap(find.text('Mavjud'));
    await pumpFor(t, 500);
    expect(find.text('5 ta mos mahsulot'), findsWidgets);
    ok('in-stock chip (all in stock)');
    await t.tap(find.text('Soatlar').first);
    await pumpFor(t, 500);
    expect(find.byIcon(Icons.close_rounded), findsWidgets);
    ok('category chip selected (with ✕)');

    await t.tap(find.text("Do'konlar"));
    await waitFor(t, find.text("MOS DO'KONLAR"), why: 'shops tab');
    ok('shops tab');
    await pumpFor(t, 1000); // let the tab slide finish
    await t.tap(find.byType(SearchShopRow).first);
    await pumpFor(t, 1200);
    expect(find.byType(SearchProductCard), findsWidgets);
    ok('shop row → products tab filtered');

    // --- Scope sheet ---------------------------------------------------------------
    await t.tap(find.text('Natijalar: Barchasi'));
    await waitFor(t, find.text("Qaysi bo'limda qidiramiz?"), why: 'scope sheet');
    // The option list is lazy: scroll the sheet until the option is built.
    for (var i = 0; i < 10 && find.text('Texnologiya').evaluate().isEmpty; i++) {
      await t.drag(find.byType(ListView).last, const Offset(0, -150));
      await pumpFor(t, 300);
    }
    await t.tap(find.text('Texnologiya').last);
    await waitFor(t, find.text('Natijalar: Texnologiya'), why: 'scoped results');
    await waitFor(t, find.text('5 ta mos mahsulot'), why: 'scoped count');
    ok('scope → Texnologiya, still 5');

    // --- Editing goes back to suggestions; clear → recent ----------------------------
    await t.enterText(find.byType(TextField), 'iph');
    await waitFor(t, find.text('Boshqa mos natijalar'), why: 'suggestions after edit');
    expect(find.textContaining('Natijalar:'), findsNothing);
    ok('edit → suggestions again');
    await t.tap(find.byTooltip('Tozalash'));
    await waitFor(t, find.text("SO'NGGI QIDIRUVLAR"), why: 'recent searches');
    expect(find.text('soat'), findsOneWidget);
    ok('clear → recent has "soat"');

    await t.tap(find.byTooltip('Back'));
    await waitFor(t, find.text('Xush kelibsiz!'), why: 'back home');
    ok('back → home');

    // ignore: avoid_print
    print('ALL STEPS:\n${log.join('\n')}');
  });
}
