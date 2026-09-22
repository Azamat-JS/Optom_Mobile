import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/features/catalog/domain/entities/catalog_product.dart';
import 'package:bsmart/features/catalog/domain/entities/catalog_seller.dart';

class CreateOrderCartLine {
  const CreateOrderCartLine({required this.product, required this.quantity, required this.unitPrice, this.discount = 0});

  final CatalogProduct product;
  final double quantity;
  final double unitPrice;
  final double discount;

  double get total => quantity * unitPrice - discount;

  CreateOrderCartLine copyWith({double? quantity, double? unitPrice, double? discount}) {
    return CreateOrderCartLine(
      product: product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
    );
  }
}

class CreateOrderCartState {
  const CreateOrderCartState({this.seller, this.store, this.lines = const {}});

  final CatalogSeller? seller;
  final CatalogStore? store;

  /// Keyed by `productId` — a cart can only hold products from one seller,
  /// one store, and one currency at a time (mirrors the backend's
  /// single-currency/single-store-per-order invariants, enforced again
  /// server-side regardless — see `order.service.ts`).
  final Map<String, CreateOrderCartLine> lines;

  double get total => lines.values.fold(0, (sum, line) => sum + line.total);
  int get itemCount => lines.length;
  bool get isEmpty => lines.isEmpty;
}

class CreateOrderCartNotifier extends Notifier<CreateOrderCartState> {
  @override
  CreateOrderCartState build() => const CreateOrderCartState();

  void selectSeller(CatalogSeller seller) => state = CreateOrderCartState(seller: seller);

  void selectStore(CatalogStore? store) =>
      state = CreateOrderCartState(seller: state.seller, store: store, lines: state.lines);

  /// Returns `false` (leaving the cart unchanged) if [product] would mix
  /// currencies with what's already in the cart — the caller should surface
  /// this as a toast, matching the reference web app's POS cart guard.
  bool addProduct(CatalogProduct product) {
    if (state.lines.isNotEmpty) {
      final existingCurrency = state.lines.values.first.product.currency;
      if (existingCurrency != product.currency) return false;
    }

    final existing = state.lines[product.id];
    final updated = Map<String, CreateOrderCartLine>.from(state.lines);
    updated[product.id] = existing == null
        ? CreateOrderCartLine(product: product, quantity: 1, unitPrice: product.price)
        : existing.copyWith(quantity: existing.quantity + 1);

    state = CreateOrderCartState(seller: state.seller, store: state.store, lines: updated);
    return true;
  }

  void updateQuantity(String productId, double quantity) {
    final existing = state.lines[productId];
    if (existing == null) return;
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final updated = Map<String, CreateOrderCartLine>.from(state.lines);
    updated[productId] = existing.copyWith(quantity: quantity);
    state = CreateOrderCartState(seller: state.seller, store: state.store, lines: updated);
  }

  void removeProduct(String productId) {
    final updated = Map<String, CreateOrderCartLine>.from(state.lines)..remove(productId);
    state = CreateOrderCartState(seller: state.seller, store: state.store, lines: updated);
  }

  void clear() => state = const CreateOrderCartState();
}

final createOrderCartProvider = NotifierProvider<CreateOrderCartNotifier, CreateOrderCartState>(
  CreateOrderCartNotifier.new,
);
