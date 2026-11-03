import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/products/domain/entities/product.dart';
import 'package:bsmart/features/sales/domain/pricing/discount_limit.dart';
import 'package:bsmart/features/sales/domain/pricing/special_pricing.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

class PosCartLine {
  const PosCartLine({required this.product, required this.quantity, this.discountPercent = 0});

  final Product product;
  final double quantity;

  /// The line's discount in %, as chosen; capped at the owner's limit for the line's price (see
  /// `discount_limit.dart`), which depends on the customer.
  final double discountPercent;

  double get total => totalFor(specialCustomer: false);

  /// The discount amount at the stock price (what a parked cart stores).
  double get discount => discountFor(specialCustomer: false);

  /// The line's unit price for the chosen customer — a special one pays the retail price.
  double unitPriceFor({required bool specialCustomer}) => effectiveUnitPrice(product, specialCustomer: specialCustomer);

  /// The most % this line may take off for the chosen customer (null = no limit).
  double? maxPercentFor({required bool specialCustomer}) =>
      maxLineDiscountPercent(product, unitPriceFor(specialCustomer: specialCustomer));

  double percentFor({required bool specialCustomer}) {
    final max = maxPercentFor(specialCustomer: specialCustomer) ?? 100;
    return discountPercent.clamp(0, max).toDouble();
  }

  /// The discount amount sent with the line, rounded to cents.
  double discountFor({required bool specialCustomer}) => lineDiscountAmount(
    quantity,
    unitPriceFor(specialCustomer: specialCustomer),
    percentFor(specialCustomer: specialCustomer),
  );

  double totalFor({required bool specialCustomer}) =>
      quantity * unitPriceFor(specialCustomer: specialCustomer) - discountFor(specialCustomer: specialCustomer);

  PosCartLine copyWith({double? quantity, double? discountPercent}) {
    return PosCartLine(
      product: product,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}

/// The POS Sell tab's cart — plain, ephemeral `Notifier` state (mirrors
/// `CreateOrderCartNotifier`'s shape/currency-guard exactly, see
/// `order.service.ts`'s equivalent single-currency invariant for `Sale`).
class PosCartState {
  const PosCartState({this.lines = const {}, this.saleDiscount = 0});

  final Map<String, PosCartLine> lines;
  final double saleDiscount;

  double get subtotal => subtotalFor(specialCustomer: false);

  /// Checkout's subtotal once the customer is known (the Sell tab doesn't know it yet).
  double subtotalFor({required bool specialCustomer}) =>
      lines.values.fold(0, (sum, line) => sum + line.totalFor(specialCustomer: specialCustomer));
  double get total => (subtotal - saleDiscount).clamp(0, double.infinity);
  int get itemCount => lines.length;
  bool get isEmpty => lines.isEmpty;
  Currency? get currency => lines.values.isEmpty ? null : lines.values.first.product.currency;
}

class PosCartNotifier extends Notifier<PosCartState> {
  @override
  PosCartState build() {
    ref.watch(currentUserIdProvider);
    return const PosCartState();
  }

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

  /// Sets a line's discount in %, clamped to what the product's owner allows at its stock price.
  void setDiscountPercent(String productId, double percent) {
    final existing = state.lines[productId];
    if (existing == null) return;
    final max = existing.maxPercentFor(specialCustomer: false) ?? 100;
    final updated = Map<String, PosCartLine>.from(state.lines);
    updated[productId] = existing.copyWith(discountPercent: percent.clamp(0, max).toDouble());
    state = PosCartState(lines: updated, saleDiscount: state.saleDiscount);
  }

  void removeProduct(String productId) {
    final updated = Map<String, PosCartLine>.from(state.lines)..remove(productId);
    state = PosCartState(lines: updated, saleDiscount: state.saleDiscount);
  }

  void setDiscount(double discount) => state = PosCartState(lines: state.lines, saleDiscount: discount);

  void clear() => state = const PosCartState();

  /// Replaces the cart wholesale from a resumed parked cart — bypasses
  /// [addProduct]'s accumulate/currency-guard logic entirely, since the
  /// caller (restoring a `SharedCart`) already re-fetched each live
  /// [Product] and is responsible for having done so for a consistent
  /// currency set. Any product that no longer exists must be filtered out
  /// by the caller before calling this (see `SharedCartSheet._restore`).
  void loadCart(List<PosCartLine> lines, {double saleDiscount = 0}) {
    state = PosCartState(lines: {for (final line in lines) line.product.id: line}, saleDiscount: saleDiscount);
  }
}

final posCartProvider = NotifierProvider<PosCartNotifier, PosCartState>(PosCartNotifier.new);
