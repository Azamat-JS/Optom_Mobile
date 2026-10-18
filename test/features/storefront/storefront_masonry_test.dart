import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_masonry.dart';

StorefrontProduct _p(String id, {bool photo = false}) => StorefrontProduct(
  id: id,
  name: id,
  price: 1,
  currency: Currency.uzs,
  stock: 1,
  sellerId: 's',
  sellerName: 'S',
  sellerPhone: '',
  imageUrl: photo ? 'https://img/$id.jpg' : null,
);

void main() {
  test('big slots (5, 6) get photo products; nothing is lost or duplicated', () {
    final products = [for (var i = 0; i < 9; i++) _p('p$i', photo: i == 0 || i == 8)];
    final ordered = StorefrontMasonry.photosInBigSlots(products);
    expect(ordered.map((p) => p.id).toSet(), products.map((p) => p.id).toSet());
    expect(ordered, hasLength(9));
    expect(ordered[5].id, 'p0');
    expect(ordered[6].id, 'p8');
    // Others keep their relative order.
    expect(
      [
        for (var i = 0; i < 9; i++)
          if (i != 5 && i != 6) ordered[i].id,
      ],
      ['p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7'],
    );
  });

  test('no photos, or a partial block → order unchanged', () {
    final noPhotos = [for (var i = 0; i < 9; i++) _p('p$i')];
    expect(StorefrontMasonry.photosInBigSlots(noPhotos).map((p) => p.id), noPhotos.map((p) => p.id));
    final partial = [for (var i = 0; i < 5; i++) _p('p$i', photo: true)];
    expect(StorefrontMasonry.photosInBigSlots(partial).map((p) => p.id), partial.map((p) => p.id));
  });
}
