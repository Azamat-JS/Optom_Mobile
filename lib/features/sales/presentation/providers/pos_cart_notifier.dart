import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';

class PosCartLine {
  const PosCartLine({required this.product, required this.quantity, this.discount = 0});

  final Product product;
  final double quantity;
  final double discount;

  double get total => quantity * product.price - discount;

  PosCartLine copyWith({double? quantity, double? discount}) {
    return PosCartLine(product: product, quantity: quantity ?? this.quantity, discount: discount ?? this.discount);
  }
}

/// The POS Sell tab's cart — plain, ephemeral `Notifier` state (mirrors
/// `CreateOrderCartNotifier`'s shape/currency-guard exactly, see
/// `order.service.ts`'s equivalent single-currency invariant for `Sale`).
class PosCartState {
  const PosCartState({this.lines = const {}, this.saleDiscount = 0});

  final Map<String, PosCartLine> lines;
  final double saleDiscount;

  double get subtotal => lines.values.fold(0, (sum, line) => sum + line.total);
  double get total => (subtotal - saleDiscount).clamp(0, double.infinity);
  int get itemCount => lines.length;
  bool get isEmpty => lines.isEmpty;
  Currency? get currency => lines.values.isEmpty ? null : lines.values.first.product.currency;
}

class PosCartNotifier extends Notifier<PosCartState> {
  @override
  PosCartState build() => const PosCartState();

  /// Returns `false` (leaving the cart unchanged) if [product] would mix
  /// currencies with what's already in the cart — the caller should surface
  /// this as a toast, mirroring `sale.service.ts`'s server-side guard.
  bool addProduct(Product product) {
    if (state.lines.isNotEmpty && state.currency != product.currency) return false;

    final existing = state.lines[product.id];
    final updated = Map<String, PosCartLine>.from(state.lines);
    updated[product.id] = existing == null
        ? PosCartLine(product: product, quantity: 1)
        : existing.copyWith(quantity: existing.quantity + 1);

    state = PosCartState(lines: updated, saleDiscount: state.saleDiscount);
    return true;
  }

  void updateQuantity(String productId, double quantity) {
    final existing = state.lines[productId];
    if (existing == null) return;
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final updated = Map<String, PosCartLine>.from(state.lines);
    updated[productId] = existing.copyWith(quantity: quantity);
    state = PosCartState(lines: updated, saleDiscount: state.saleDiscount);
  }

  void removeProduct(String productId) {
    final updated = Map<String, PosCartLine>.from(state.lines)..remove(productId);
    state = PosCartState(lines: updated, saleDiscount: state.saleDiscount);
  }

  void setDiscount(double discount) => state = PosCartState(lines: state.lines, saleDiscount: discount);

  void clear() => state = const PosCartState();
}

final posCartProvider = NotifierProvider<PosCartNotifier, PosCartState>(PosCartNotifier.new);
