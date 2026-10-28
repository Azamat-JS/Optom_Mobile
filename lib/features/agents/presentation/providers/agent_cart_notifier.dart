import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';

class AgentCartLine {
  const AgentCartLine({required this.item, required this.quantity, required this.unitPrice});

  final AgentStockItem item;
  final double quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;

  AgentCartLine copyWith({double? quantity, double? unitPrice}) =>
      AgentCartLine(item: item, quantity: quantity ?? this.quantity, unitPrice: unitPrice ?? this.unitPrice);
}

/// The agent's sell cart — one currency per sale (same guard as `PosCartNotifier`). A new line
/// starts at quantity 1 and the top of the owner's range; the server re-checks every price.
class AgentCartNotifier extends Notifier<List<AgentCartLine>> {
  @override
  List<AgentCartLine> build() => const [];

  Currency? get currency => state.isEmpty ? null : state.first.item.currency;

  /// False (no change) when the product's currency differs from the cart's.
  bool add(AgentStockItem item) {
    if (currency != null && item.currency != currency) return false;
    if (state.any((l) => l.item.id == item.id)) return true;
    state = [...state, AgentCartLine(item: item, quantity: 1, unitPrice: item.maxPrice)];
    return true;
  }

  void remove(String itemId) => state = [for (final l in state) if (l.item.id != itemId) l];

  void update(String itemId, {double? quantity, double? unitPrice}) => state = [
        for (final l in state) l.item.id == itemId ? l.copyWith(quantity: quantity, unitPrice: unitPrice) : l,
      ];

  void clear() => state = const [];
}

final agentCartProvider = NotifierProvider<AgentCartNotifier, List<AgentCartLine>>(AgentCartNotifier.new);
