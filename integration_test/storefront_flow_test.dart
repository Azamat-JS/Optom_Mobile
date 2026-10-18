// Manual verification test (Phase 9 U2a/U2b): drives the real app on a simulator
// against the LOCAL backend as a guest. It relies on local dev data (shops
// "Osh markazi"/"Davron market", five "soat" products, a "Texnologiya"
// category), so it is not part of `flutter test`. Run with:
//   flutter test integration_test/storefront_flow_test.dart -d <simulator>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bsmart/bootstrap.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_masonry.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_shop_parts.dart';

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

/// Scrolls the page back to the top, then taps the header's back arrow.
Future<void> backFromTop(WidgetTester t) async {
  // `.last` = the top route (a covered route can still be in the tree).
  await t.drag(mainScroll.last, const Offset(0, 6000));
  await pumpFor(t, 800);
  await t.tap(find.byIcon(Icons.arrow_back_rounded).last);
  await pumpFor(t, 1200);
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

    // --- Shop page (U2c) ------------------------------------------------------
    await waitFor(t, find.text("Do'konlar"), why: 'shop strip');
    await t.tap(find.text('Davron market').first);
    await waitFor(t, find.textContaining('dan qidiring'), why: 'shop page');
    await waitFor(t, find.byType(ShopSectionHeader), why: 'shop sections');
    expect(find.text('Davron Odilov'), findsOneWidget);
    ok('shop card → shop page (owner row, sections)');

    await t.enterText(find.byType(TextField), 'soat');
    await pumpFor(t, 800);
    expect(find.textContaining('Soatlar ('), findsOneWidget);
    expect(find.textContaining('Kiyimlar ('), findsNothing);
    ok('in-shop search "soat" → only Soatlar');
    await t.tap(find.byTooltip('Tozalash'));
    await pumpFor(t, 800);

    await t.tap(find.textContaining('Kiyimlar ('));
    await pumpFor(t, 800);
    expect(find.text('Pechenye'), findsNothing);
    ok('section collapses');
    await t.tap(find.textContaining('Kiyimlar ('));
    await pumpFor(t, 800);
    expect(find.text('Pechenye'), findsOneWidget);
    ok('section expands');

    await t.tap(find.text('MENYU'));
    await waitFor(t, find.byType(ShopMenuPanel), why: 'menu panel');
    await t.tap(find.descendant(of: find.byType(ShopMenuPanel), matching: find.text('Telefonlar')));
    await pumpFor(t, 1500);
    final header = find.textContaining('Telefonlar (');
    expect(header, findsOneWidget);
    final y = t.getTopLeft(header).dy;
    expect(y, inInclusiveRange(150, 420), reason: 'section header right under the pinned bar (y=$y)');
    ok('MENYU → jumps to Telefonlar (y=${y.round()})');

    // --- U2d: mosaic + product page ---------------------------------------------
    await t.tap(find.byTooltip("Rasmlar bilan ko'rish"));
    await waitFor(t, find.byType(StorefrontMasonry), why: 'explore mosaic');
    ok('shop → photo mosaic');
    await t.enterText(find.byType(TextField).last, 'soat');
    await pumpFor(t, 600);
    expect(find.text('Soat 330'), findsOneWidget);
    expect(find.text('Pechenye'), findsNothing);
    ok('mosaic search "soat"');
    await t.tap(find.text('Soat 330'));
    await waitFor(t, find.text("Do'konga o'tish"), why: 'product page');
    expect(find.text('Tavsif'), findsOneWidget);
    ok('tile → product page (description, shop card)');
    await t.tap(find.text("QO'SHISH").last);
    await waitFor(t, find.text('Savatda: 1'), why: 'in-cart line');
    ok('product page ADD → "Savatda: 1"');
    await t.tap(find.byIcon(Icons.remove_rounded).last);
    await pumpFor(t, 500);
    expect(find.text('Savatda: 1'), findsNothing);
    ok('product page − → removed');
    await t.tap(find.text("Do'konga o'tish"));
    await waitFor(t, find.textContaining('dan qidiring'), why: 'shop from product');
    ok('shop card → shop page');
    await backFromTop(t);
    await waitFor(t, find.text("Do'konga o'tish"), why: 'back to product');
    await t.tap(find.byIcon(Icons.arrow_back_rounded).last);
    await waitFor(t, find.byType(StorefrontMasonry), why: 'back to mosaic');
    await t.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await pumpFor(t, 1200);
    ok('back → product → mosaic → shop');

    await tapVisible(t, find.text("QO'SHISH"));
    await waitFor(t, find.byIcon(Icons.remove_rounded), why: 'shop stepper');
    await tapVisible(t, find.byIcon(Icons.remove_rounded));
    await pumpFor(t, 500);
    ok('ADD on shop page → stepper → removed');

    await backFromTop(t);
    await waitFor(t, find.text('Xush kelibsiz!'), why: 'back home from shop');
    ok('shop → back home');

    // --- Add to cart, stepper, badge -----------------------------------------
    await scrollToFind(t, find.text("QO'SHISH"));
    await tapVisible(t, find.text("QO'SHISH"));
    await pumpFor(t, 600);
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
    await waitFor(t, find.textContaining('dan qidiring'), why: 'shop page from search');
    ok('shop row → shop page');
    await backFromTop(t);
    await waitFor(t, find.text('Natijalar: Barchasi'), why: 'back to results');
    ok('shop page → back to results');

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
    await t.tap(find.byType(TextField));
    await pumpFor(t, 800);
    await t.enterText(find.byType(TextField), 'iph');
    await pumpFor(t, 2500);
    await waitFor(t, find.text('Boshqa mos natijalar'), why: 'suggestions after edit');
    expect(find.textContaining('Natijalar:'), findsNothing);
    ok('edit → suggestions again');
    await t.tap(find.byTooltip('Tozalash'));
    await waitFor(t, find.text("SO'NGGI QIDIRUVLAR"), why: 'recent searches');
    expect(find.text('soat'), findsOneWidget);
    ok('clear → recent has "soat"');

    await t.tap(find.byIcon(Icons.arrow_back_rounded));
    await waitFor(t, find.text('Xush kelibsiz!'), why: 'back home');
    ok('back → home');

    // ignore: avoid_print
    print('ALL STEPS:\n${log.join('\n')}');
  });
}
