import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/features/storefront/domain/entities/storefront_product.dart';

class StorefrontCartLine {
  const StorefrontCartLine({required this.product, required this.quantity});

  final StorefrontProduct product;
  final double quantity;

  double get total => quantity * product.price;

  StorefrontCartLine copyWith({double? quantity}) =>
      StorefrontCartLine(product: product, quantity: quantity ?? this.quantity);
}

/// Keyed by `productId` — mirrors the backend's own single-seller invariant
/// (`CreateOrderDto.sellerId` is one field, so an order can only ever be
/// placed against one retailer at a time; see `order.service.ts`'s
/// currency-mixing guard for the same category of constraint).
class StorefrontCartState {
  const StorefrontCartState({this.lines = const {}});

  final Map<String, StorefrontCartLine> lines;

  double get total => lines.values.fold(0, (sum, line) => sum + line.total);
  int get itemCount => lines.length;
  bool get isEmpty => lines.isEmpty;
  String? get sellerId => lines.values.firstOrNull?.product.sellerId;
  String? get sellerName => lines.values.firstOrNull?.product.sellerName;
}

/// Local-only cart state (no persisted `Cart` model, same pattern as
/// `CreateOrderCartNotifier`/`PosCartNotifier`) for the guest-eligible
/// storefront. A guest may freely build this cart while browsing — only
/// submitting it (`GoRoute` to `RouteNames.customerCartReview` →
/// `POST /orders`) requires being logged in, enforced by the router
/// redirect, not here.
class StorefrontCartNotifier extends Notifier<StorefrontCartState> {
  @override
  StorefrontCartState build() => const StorefrontCartState();

  /// Returns `false` (cart left unchanged) if [product] belongs to a
  /// different seller or currency than what's already in the cart — the
  /// caller should surface this as a toast, matching every other cart in
  /// this app (`PosCartNotifier`/`CreateOrderCartNotifier`).
  bool addProduct(StorefrontProduct product) {
    if (state.lines.isNotEmpty) {
      final first = state.lines.values.first.product;
      if (first.sellerId != product.sellerId || first.currency != product.currency) return false;
    }

    final existing = state.lines[product.id];
    final updated = Map<String, StorefrontCartLine>.from(state.lines);
    updated[product.id] = existing == null
        ? StorefrontCartLine(product: product, quantity: 1)
        : existing.copyWith(quantity: existing.quantity + 1);
    state = StorefrontCartState(lines: updated);
    return true;
  }

  void updateQuantity(String productId, double quantity) {
    final existing = state.lines[productId];
    if (existing == null) return;
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final updated = Map<String, StorefrontCartLine>.from(state.lines);
    updated[productId] = existing.copyWith(quantity: quantity);
    state = StorefrontCartState(lines: updated);
  }

  void removeProduct(String productId) {
    final updated = Map<String, StorefrontCartLine>.from(state.lines)..remove(productId);
    state = StorefrontCartState(lines: updated);
  }

  void clear() => state = const StorefrontCartState();
}

final storefrontCartProvider = NotifierProvider<StorefrontCartNotifier, StorefrontCartState>(
  StorefrontCartNotifier.new,
);
