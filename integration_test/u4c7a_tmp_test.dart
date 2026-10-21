// TEMPORARY (Phase 9 U4c7a check): a throwaway RESTAURANT retailer and its
// waiter (seeded menu, tables, two open orders): tables add/delete, order
// board, detail with a status step, a new dine-in order; then the waiter's
// shell (orders, menu). Light, then dark. Deleted after the check.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bsmart/bootstrap.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_bottom_nav.dart';

Future<void> pumpFor(WidgetTester t, [int ms = 1200]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> waitFor(WidgetTester t, Finder f, {int timeoutMs = 20000, String? why}) async {
  for (var waited = 0; waited < timeoutMs; waited += 100) {
    if (f.evaluate().isNotEmpty) return;
    await t.pump(const Duration(milliseconds: 100));
  }
  fail('Timed out waiting for ${why ?? f}');
}

void shot(String name) {
  // ignore: avoid_print
  print('SHOT:$name');
}

void ok(String step) {
  // ignore: avoid_print
  print('STEP OK: $step');
}

Finder vis(Finder f) => f.hitTestable();

Finder nav(String label) =>
    find.descendant(of: find.byType(StorefrontBottomNav), matching: find.text(label));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('U4c7a restaurant screens', (t) async {
    await bootstrap();
    await waitFor(t, find.byType(Scaffold), why: 'app');
    await pumpFor(t, 2000);
    BuildContext ctx() => t.element(find.byType(Scaffold).last);
    final container = ProviderScope.containerOf(ctx());

    Future<void> logout() async {
      if (container.read(sessionNotifierProvider).valueOrNull?.isAuthenticated ?? false) {
        await container.read(sessionNotifierProvider.notifier).logout();
        await pumpFor(t, 2500);
      }
    }

    Future<void> login(String phone) async {
      await logout();
      GoRouter.of(ctx()).go(RouteNames.login);
      await waitFor(t, find.text('Parol bilan kirish'), why: 'login');
      await t.enterText(find.byType(TextField).first, phone);
      await pumpFor(t, 300);
      await t.tap(find.text('Parol bilan kirish'));
      await pumpFor(t, 800);
      await t.enterText(find.byType(TextField).last, 'Test1234');
      await pumpFor(t, 300);
      await t.tap(find.widgetWithText(OutlinedButton, 'Kirish'));
      await pumpFor(t, 5000);
    }

    Future<void> back() async {
      await t.tap(vis(find.byIcon(Icons.arrow_back_rounded)).first);
      await pumpFor(t, 1500);
    }

    // ---------- owner: tables ----------
    await login('900000778');
    GoRouter.of(ctx()).push(RouteNames.restaurantTables);
    await waitFor(t, find.text('VIP'), why: 'tables');
    await pumpFor(t, 1500);
    shot('light_tables');
    await pumpFor(t, 500);
    await t.tap(vis(find.byIcon(Icons.add_rounded)));
    await waitFor(t, find.text('Yangi stol'), why: 'table form');
    await pumpFor(t, 800);
    await t.enterText(find.byType(TextFormField).first, '7');
    await t.enterText(find.byType(TextFormField).last, '12');
    await pumpFor(t, 500);
    shot('light_table_form');
    await pumpFor(t, 500);
    await t.tap(find.text('Saqlash'));
    await waitFor(t, vis(find.text('7')), why: 'new table');
    await pumpFor(t, 1500);
    expect(vis(find.text('Xizmat haqi: 12%')), findsOneWidget);
    shot('light_tables_added');
    await pumpFor(t, 500);
    // Its menu: the 4th card (1, 2, 7, VIP sorted by the backend — find it by text instead).
    final card7 = find.ancestor(of: find.text('7'), matching: find.byType(Column)).first;
    await t.tap(find.descendant(of: card7, matching: find.byIcon(Icons.more_horiz_rounded)).first);
    await pumpFor(t, 800);
    await t.tap(find.text("O'chirish").last);
    await pumpFor(t, 800);
    await t.tap(find.widgetWithText(FilledButton, "O'chirish"));
    await pumpFor(t, 2500);
    expect(vis(find.text('Xizmat haqi: 12%')), findsNothing);
    ok('tables add + delete');
    await back();

    // ---------- owner: board, detail ----------
    GoRouter.of(ctx()).push(RouteNames.restaurantOrders);
    await waitFor(t, find.text('Dilshod'), why: 'board');
    await pumpFor(t, 1500);
    expect(vis(find.text('Stol: 2')), findsOneWidget);
    shot('light_board');
    await pumpFor(t, 500);
    await t.tap(vis(find.text('Dilshod')));
    await waitFor(t, find.text('Tayyorlashni boshlash'), why: 'delivery detail');
    await pumpFor(t, 1500);
    shot('light_detail_delivery');
    await pumpFor(t, 500);
    await t.drag(find.byType(ListView).last, const Offset(0, -600));
    await pumpFor(t, 1200);
    shot('light_detail_delivery_courier');
    await pumpFor(t, 500);
    await t.tap(find.text('Tayyorlashni boshlash'));
    await waitFor(t, find.text('Tayyor deb belgilash'), why: 'status step');
    await pumpFor(t, 1000);
    expect(vis(find.text('Tayyorlanmoqda')), findsOneWidget);
    ok('detail status step');
    await back();

    // ---------- owner: new dine-in order ----------
    await t.tap(vis(find.byIcon(Icons.add_rounded)));
    await waitFor(t, find.text('Yangi buyurtma'), why: 'create');
    await pumpFor(t, 1500);
    await t.tap(vis(find.text('VIP')));
    await pumpFor(t, 500);
    await t.tap(vis(find.text("Qo'shish")));
    await waitFor(t, find.text('Manti'), why: 'menu sheet');
    await pumpFor(t, 1200);
    shot('light_menu_sheet');
    await pumpFor(t, 500);
    await t.tap(find.text('Manti'));
    await pumpFor(t, 1200);
    await t.tap(vis(find.byIcon(Icons.add_rounded)).last);
    await pumpFor(t, 600);
    expect(vis(find.textContaining(RegExp(r'64\s000'))), findsWidgets);
    shot('light_create');
    await pumpFor(t, 500);
    await t.tap(vis(find.text('Buyurtma berish')));
    await waitFor(t, vis(find.text('Stol: VIP')), why: 'new order on the board');
    await pumpFor(t, 1500);
    shot('light_board_after');
    await pumpFor(t, 500);
    ok('new dine-in order');

    // ---------- waiter ----------
    await login('900000780');
    await waitFor(t, find.byType(StorefrontBottomNav), why: 'waiter home');
    await waitFor(t, find.text('Stol: VIP'), why: 'waiter board');
    await pumpFor(t, 1500);
    shot('light_waiter_orders');
    await pumpFor(t, 500);
    await t.tap(nav('Menyu'));
    await waitFor(t, vis(find.text('Osh')), why: 'waiter menu');
    await pumpFor(t, 1500);
    shot('light_waiter_menu');
    await pumpFor(t, 500);
    ok('waiter shell');

    // ---------- dark ----------
    // ignore: avoid_print
    print('WAIT:dark');
    await pumpFor(t, 6000);
    shot('dark_waiter_menu');
    await pumpFor(t, 500);
    await t.tap(nav('Buyurtmalar'));
    await pumpFor(t, 1500);
    shot('dark_waiter_orders');
    await pumpFor(t, 500);
    await t.tap(vis(find.text('Stol: 2')));
    await waitFor(t, find.text('Tayyor deb belgilash'), why: 'dark detail');
    await pumpFor(t, 1500);
    shot('dark_detail_dinein');
    await pumpFor(t, 500);
    await back();
    await t.tap(vis(find.byIcon(Icons.add_rounded)));
    await waitFor(t, find.text('Yangi buyurtma'), why: 'dark create');
    await pumpFor(t, 1500);
    shot('dark_create');
    await pumpFor(t, 500);
    await back();
    await login('900000778');
    GoRouter.of(ctx()).push(RouteNames.restaurantTables);
    await waitFor(t, find.text('VIP'), why: 'dark tables');
    await pumpFor(t, 1500);
    shot('dark_tables');
    await pumpFor(t, 500);
    ok('dark');
  });
}
