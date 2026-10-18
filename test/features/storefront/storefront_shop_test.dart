import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';
import 'package:bsmart/features/storefront/domain/entities/storefront_shop.dart';

StorefrontProduct _product(String id, String sellerId, {String? storeName, String? imageUrl}) => StorefrontProduct(
  id: id,
  name: 'Product $id',
  price: 1000,
  currency: Currency.uzs,
  stock: 5,
  sellerId: sellerId,
  sellerName: 'Owner $sellerId',
  sellerPhone: '+998900000000',
  storeName: storeName,
  imageUrl: imageUrl,
);

void main() {
  test('one shop per seller, in feed order', () {
    final shops = StorefrontShop.fromProducts([
      _product('1', 'a', storeName: 'Alpha'),
      _product('2', 'b', storeName: 'Beta'),
      _product('3', 'a', storeName: 'Alpha'),
    ]);
    expect(shops.map((s) => s.sellerId), ['a', 'b']);
    expect(shops.map((s) => s.name), ['Alpha', 'Beta']);
  });

  test('uses the first product photo of the shop, even if a later product has it', () {
    final shops = StorefrontShop.fromProducts([
      _product('1', 'a', storeName: 'Alpha'),
      _product('2', 'a', storeName: 'Alpha', imageUrl: 'https://img/2.jpg'),
      _product('3', 'a', storeName: 'Alpha', imageUrl: 'https://img/3.jpg'),
    ]);
    expect(shops.single.imageUrl, 'https://img/2.jpg');
  });

  test("falls back to the owner's name without a store name", () {
    final shops = StorefrontShop.fromProducts([_product('1', 'a', storeName: '  ')]);
    expect(shops.single.name, 'Owner a');
  });

  test('caps the strip', () {
    final products = [for (var i = 0; i < 20; i++) _product('$i', 's$i', imageUrl: 'https://img/$i.jpg')];
    expect(StorefrontShop.fromProducts(products, limit: 5), hasLength(5));
  });
}
