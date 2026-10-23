// TEMPORARY (Phase 9 U5a visual check) — delete after the run.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/app_l10n.dart';
import 'package:bsmart/core/storage/hive_boxes.dart';
import 'package:bsmart/core/theme/app_theme.dart';
import 'package:bsmart/features/categories/domain/entities/category.dart';
import 'package:bsmart/features/categories/presentation/providers/categories_provider.dart';
import 'package:bsmart/features/categories/presentation/widgets/category_picker_field.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/sales/domain/entities/shared_cart.dart';
import 'package:bsmart/features/sales/presentation/providers/pos_cart_notifier.dart';
import 'package:bsmart/features/sales/presentation/providers/shared_carts_notifier.dart';
import 'package:bsmart/features/sales/presentation/widgets/customer_picker_sheet.dart';
import 'package:bsmart/features/sales/presentation/widgets/shared_cart_sheet.dart';
import 'package:bsmart/l10n/app_localizations.dart';
import 'package:bsmart/shared/widgets/barcode_scanner_screen.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/location_picker_field.dart';
import 'package:bsmart/shared/widgets/map_pin_picker_screen.dart';

final _nav = GlobalKey<NavigatorState>();
final _mode = ValueNotifier(ThemeMode.light);
final _locale = ValueNotifier(const Locale('uz'));

class _FakeCarts extends SharedCartsNotifier {
  @override
  Future<List<SharedCart>> build() async => [
    SharedCart(
      id: 'c1',
      currency: Currency.uzs,
      items: const [
        SharedCartItem(productId: 'p1', productName: 'Coca-Cola 1.5L', quantity: 2, unitPrice: 14000),
        SharedCartItem(productId: 'p2', productName: 'Non', quantity: 3, unitPrice: 4000),
        SharedCartItem(productId: 'p3', productName: 'Sut 1L', quantity: 1, unitPrice: 12000),
        SharedCartItem(productId: 'p4', productName: 'Tuxum', quantity: 10, unitPrice: 1500),
      ],
      customAmount: 0,
      saleDiscount: 0,
      createdAt: DateTime(2026, 10, 23, 9, 41),
    ),
    SharedCart(
      id: 'c2',
      currency: Currency.usd,
      items: const [SharedCartItem(productId: 'p5', productName: 'iPhone case', quantity: 1, unitPrice: 12)],
      customAmount: 0,
      saleDiscount: 0,
      createdAt: DateTime(2026, 10, 23, 11, 5),
    ),
  ];
}

class _FakeCategories extends CategoriesNotifier {
  @override
  Future<List<Category>> build() async => const [
    Category(
      id: 'r1',
      name: 'Oziq-ovqat',
      slug: 'food',
      sortOrder: 0,
      isActive: true,
      children: [
        Category(id: 'c1', name: 'Ichimliklar', slug: 'drinks', sortOrder: 0, isActive: true, parentId: 'r1', parentName: 'Oziq-ovqat'),
        Category(id: 'c2', name: 'Non mahsulotlari', slug: 'bread', sortOrder: 1, isActive: true, parentId: 'r1', parentName: 'Oziq-ovqat'),
        Category(id: 'c3', name: 'Sut mahsulotlari', slug: 'milk', sortOrder: 2, isActive: true, parentId: 'r1', parentName: 'Oziq-ovqat'),
      ],
    ),
    Category(id: 'r2', name: 'Texnologiya', slug: 'tech', sortOrder: 1, isActive: true),
    Category(id: 'r3', name: 'Kiyim', slug: 'clothes', sortOrder: 2, isActive: true),
  ];
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    Widget b(String key, VoidCallback onTap) =>
        ElevatedButton(key: Key(key), onPressed: onTap, child: Text(key));
    return Scaffold(
      body: SafeArea(
        child: Wrap(
          spacing: 8,
          children: [
            b('scanner', () => _nav.currentState!.push(MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()))),
            b('pin', () => MapPinPickerScreen.pick(context, title: 'Yetkazish nuqtasi', initial: const GeoPoint(41.3111, 69.2797))),
            b('form', () => _nav.currentState!.push(MaterialPageRoute(builder: (_) => const _FormPage()))),
            b('dialog', () => showDialog<void>(context: context, builder: (_) => const _StoreLikeDialog())),
            b('carts', () => SharedCartSheet.show(context)),
            b('customer', () => CustomerPickerSheet.show(context)),
          ],
        ),
      ),
    );
  }
}

class _FormPage extends StatefulWidget {
  const _FormPage();

  @override
  State<_FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<_FormPage> {
  final _form = FormGroup({'categoryId': FormControl<String>(value: 'c2')});
  GeoPoint? _pin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashColors.page(context),
      appBar: AppBar(backgroundColor: DashColors.page(context)),
      body: DashFormTheme(
        child: ReactiveForm(
          formGroup: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const TextField(decoration: InputDecoration(labelText: 'Manzil *')),
              const SizedBox(height: 12),
              const CategoryPickerField(key: Key('cat'), formControlName: 'categoryId'),
              const SizedBox(height: 12),
              LocationPickerField(value: _pin, onChanged: (p) => setState(() => _pin = p)),
              const SizedBox(height: 12),
              LocationPickerField(value: const GeoPoint(41.311081, 69.240562), onChanged: (_) {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreLikeDialog extends StatelessWidget {
  const _StoreLikeDialog();

  @override
  Widget build(BuildContext context) {
    return DashFormTheme(
      onSheet: true,
      child: AlertDialog(
        scrollable: true,
        title: const Text("Do'konni tahrirlash"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Nomi *')),
            const SizedBox(height: 12),
            LocationPickerField(value: null, onChanged: (_) {}),
            const SizedBox(height: 12),
            LocationPickerField(value: const GeoPoint(41.311081, 69.240562), onChanged: (_) {}),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () {}, child: const Text('Saqlash')),
        ],
      ),
    );
  }
}

Future<void> pumpFor(WidgetTester t, [int ms = 1200]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> shot(WidgetTester t, String name) async {
  await pumpFor(t, 900);
  // ignore: avoid_print
  print('SHOT:$name');
  await pumpFor(t, 2500);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('U5a visual check', (t) async {
    await dotenv.load(fileName: '.env');
    await Hive.initFlutter();
    await HiveBoxes.openAll();
    setupDependencyInjection();

    final container = ProviderContainer(
      overrides: [
        sharedCartsProvider.overrideWith(_FakeCarts.new),
        categoriesProvider.overrideWith(_FakeCategories.new),
      ],
    );
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ListenableBuilder(
          listenable: Listenable.merge([_mode, _locale]),
          builder: (_, _) => MaterialApp(
            navigatorKey: _nav,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _mode.value,
            locale: _locale.value,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const _Home(),
          ),
        ),
      ),
    );
    await pumpFor(t);

    for (final (mode, lang) in [(ThemeMode.light, 'uz'), (ThemeMode.dark, 'ru')]) {
      _mode.value = mode;
      _locale.value = Locale(lang);
      setActiveLanguageCode(lang);
      final tag = '${mode.name}_$lang';
      await pumpFor(t);

      await t.tap(find.byKey(const Key('scanner')));
      await shot(t, '${tag}_1_scanner');
      _nav.currentState!.pop();
      await pumpFor(t);

      await t.tap(find.byKey(const Key('pin')));
      await pumpFor(t, 3000);
      await shot(t, '${tag}_2_pin');
      _nav.currentState!.pop();
      await pumpFor(t);

      await t.tap(find.byKey(const Key('form')));
      await shot(t, '${tag}_3_form');
      await t.tap(find.byKey(const Key('cat')));
      await shot(t, '${tag}_4_category_sheet');
      await t.enterText(find.byType(TextField).last, 'non');
      await shot(t, '${tag}_5_category_search');
      _nav.currentState!.pop();
      await pumpFor(t);
      _nav.currentState!.pop();
      await pumpFor(t);

      await t.tap(find.byKey(const Key('dialog')));
      await shot(t, '${tag}_6_dialog');
      _nav.currentState!.pop();
      await pumpFor(t);

      await t.tap(find.byKey(const Key('carts')));
      await shot(t, '${tag}_7_carts_empty_cart');
      _nav.currentState!.pop();
      await pumpFor(t);
      container
          .read(posCartProvider.notifier)
          .addProduct(
            const Product(id: 'p1', name: 'Non', price: 4000, currency: Currency.uzs, stock: 50, isActive: true),
          );
      await t.tap(find.byKey(const Key('carts')));
      await shot(t, '${tag}_8_carts_with_cart');
      _nav.currentState!.pop();
      await pumpFor(t);
      container.read(posCartProvider.notifier).clear();

      await t.tap(find.byKey(const Key('customer')));
      await pumpFor(t, 2500);
      await t.tap(find.byIcon(Icons.person_add_alt_1_rounded));
      await shot(t, '${tag}_9_quick_customer');
      await t.tap(find.byType(FilledButton).last);
      await shot(t, '${tag}_10_quick_customer_errors');
      _nav.currentState!.pop();
      await pumpFor(t);
      _nav.currentState!.pop();
      await pumpFor(t);
    }
  });
}
