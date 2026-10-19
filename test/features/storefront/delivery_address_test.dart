import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/features/storefront/presentation/providers/delivery_address_providers.dart';
import 'package:bsmart/features/storefront/presentation/screens/delivery_pin_screen.dart';

const _key = 'bsmart.storefront.savedAddresses';

void main() {
  group('SavedAddress', () {
    test('splits title and rest at the first comma', () {
      const a = SavedAddress(text: "Amir Temur ko'chasi 12, Yunusobod, Toshkent");
      expect(a.title, "Amir Temur ko'chasi 12");
      expect(a.rest, 'Yunusobod, Toshkent');
      expect(const SavedAddress(text: 'Chorsu bozori').rest, isEmpty);
    });

    test('json round trip keeps the pin; bad rows are skipped', () {
      const a = SavedAddress(text: 'Chilonzor 5', point: GeoPoint(41.28, 69.2));
      final back = SavedAddress.fromJson(a.toJson())!;
      expect(back.text, 'Chilonzor 5');
      expect(back.point!.lat, 41.28);
      expect(SavedAddress.fromJson({'text': '  '}), isNull);
      expect(SavedAddress.fromJson('nonsense'), isNull);
      expect(SavedAddress.fromJson({'text': 'No pin'})!.point, isNull);
    });
  });

  group('SavedAddressesNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({_key: '[{"text":"Old, Toshkent"}]'});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('remember before the list loaded keeps the saved one; same text moves to the front', () async {
      final notifier = container.read(savedAddressesProvider.notifier);
      await notifier.remember(const SavedAddress(text: 'New, Toshkent'));
      await notifier.remember(const SavedAddress(text: 'old, toshkent'));
      expect(container.read(savedAddressesProvider).value!.map((a) => a.text), ['old, toshkent', 'New, Toshkent']);
    });

    test('caps the list and persists it', () async {
      final notifier = container.read(savedAddressesProvider.notifier);
      for (var i = 0; i < 10; i++) {
        await notifier.remember(SavedAddress(text: 'A$i'));
      }
      final saved = (await SharedPreferences.getInstance()).getString(_key)!;
      expect(container.read(savedAddressesProvider).value, hasLength(SavedAddressesNotifier.maxEntries));
      expect(saved, contains('A9'));
      expect(saved, isNot(contains('Old')));
    });

    test('the checkout starts on the most recent address, then follows the choice', () async {
      await container.read(savedAddressesProvider.future);
      final first = container.read(checkoutDeliveryProvider);
      expect(first, isA<DeliverTo>());
      expect((first! as DeliverTo).address.text, 'Old, Toshkent');
      container.read(checkoutDeliveryProvider.notifier).choose(const PickUp());
      await container.read(savedAddressesProvider.notifier).remember(const SavedAddress(text: 'Later'));
      expect(container.read(checkoutDeliveryProvider), isA<PickUp>());
    });

    test('no saved address → no choice yet', () async {
      SharedPreferences.setMockInitialValues({});
      final fresh = ProviderContainer();
      addTearDown(fresh.dispose);
      await fresh.read(savedAddressesProvider.future);
      expect(fresh.read(checkoutDeliveryProvider), isNull);
    });
  });

  group('formatPlacemark', () {
    test('street + number, district, city; skips empty and repeated parts', () {
      final p = geo.Placemark(
        name: '12',
        thoroughfare: "Amir Temur ko'chasi",
        subThoroughfare: '12',
        subLocality: 'Yunusobod',
        locality: 'Toshkent',
      );
      expect(formatPlacemark(p), "Amir Temur ko'chasi 12, Yunusobod, Toshkent");
    });

    test('falls back to the place name without a street', () {
      final p = geo.Placemark(name: 'Chorsu', subLocality: '', locality: 'Chorsu');
      expect(formatPlacemark(p), 'Chorsu');
    });
  });
}
