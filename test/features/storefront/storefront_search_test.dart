import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bsmart/features/storefront/presentation/providers/storefront_search_providers.dart';
import 'package:bsmart/features/storefront/presentation/widgets/highlight_text.dart';

const _base = TextStyle(fontWeight: FontWeight.w500);
const _match = TextStyle(fontWeight: FontWeight.w800);

/// (text, isMatch) pairs of a highlighted span.
List<(String, bool)> _parts(TextSpan span) =>
    (span.children ?? [span]).cast<TextSpan>().map((s) => (s.text!, s.style == _match)).toList();

void main() {
  group('highlightMatches', () {
    test('marks every case-insensitive occurrence, keeping the original casing', () {
      final span = highlightMatches('Pani Puri Puriwala', 'puri', base: _base, match: _match);
      expect(_parts(span), [('Pani ', false), ('Puri', true), (' ', false), ('Puri', true), ('wala', false)]);
    });

    test('no query → the plain text', () {
      final span = highlightMatches('Soat', '  ', base: _base, match: _match);
      expect(span.text, 'Soat');
      expect(span.children, isNull);
    });

    test('no occurrence → one plain part', () {
      expect(_parts(highlightMatches('Osh', 'soat', base: _base, match: _match)), [('Osh', false)]);
    });
  });

  group('RecentSearchesNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'bsmart.storefront.recentSearches': ['osh', 'soat'],
      });
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('adding before the saved list loaded keeps the saved entries', () async {
      // Called straight away, without waiting for the provider to load.
      await container.read(recentSearchesProvider.notifier).add('iphone');
      expect(container.read(recentSearchesProvider).value, ['iphone', 'osh', 'soat']);
    });

    test('moves a repeated search to the front (case-insensitive) and ignores blanks', () async {
      final notifier = container.read(recentSearchesProvider.notifier);
      await notifier.add('  SOAT ');
      await notifier.add('   ');
      expect(container.read(recentSearchesProvider).value, ['SOAT', 'osh']);
    });

    test('keeps at most ${RecentSearchesNotifier.maxEntries} and persists them', () async {
      final notifier = container.read(recentSearchesProvider.notifier);
      for (var i = 0; i < 12; i++) {
        await notifier.add('q$i');
      }
      final saved = (await SharedPreferences.getInstance()).getStringList('bsmart.storefront.recentSearches');
      expect(saved, hasLength(RecentSearchesNotifier.maxEntries));
      expect(saved!.first, 'q11');
    });

    test('clear empties the list and storage', () async {
      await container.read(recentSearchesProvider.future);
      await container.read(recentSearchesProvider.notifier).clear();
      expect(container.read(recentSearchesProvider).value, isEmpty);
      expect((await SharedPreferences.getInstance()).getStringList('bsmart.storefront.recentSearches'), isNull);
    });
  });
}
