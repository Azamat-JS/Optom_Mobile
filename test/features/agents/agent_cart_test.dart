import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/agents/domain/entities/agent_stock_item.dart';
import 'package:bsmart/features/agents/presentation/providers/agent_cart_notifier.dart';
import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';

AgentStockItem _item(String id, Currency currency, {double min = 1000, double max = 1500}) => AgentStockItem(
      id: id,
      currency: currency,
      stock: 10,
      minPrice: min,
      maxPrice: max,
      product: AgentProductRef(id: 'p$id', name: 'P$id'),
    );

void main() {
  test('a new line starts at quantity 1 and the top of the range', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(agentCartProvider.notifier).add(_item('a', Currency.uzs));
    final line = container.read(agentCartProvider).single;
    expect(line.quantity, 1);
    expect(line.unitPrice, 1500);
  });

  test('one currency per sale: a USD product is refused in a so\'m cart', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(agentCartProvider.notifier);
    expect(cart.add(_item('a', Currency.uzs)), isTrue);
    expect(cart.add(_item('b', Currency.usd)), isFalse);
    expect(cart.add(_item('c', Currency.uzs)), isTrue);
    expect(container.read(agentCartProvider).map((l) => l.item.id), ['a', 'c']);
  });

  test('update, remove and clear', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(agentCartProvider.notifier)..add(_item('a', Currency.uzs));
    cart.update('a', quantity: 3, unitPrice: 1200);
    expect(container.read(agentCartProvider).single.total, 3600);
    cart.add(_item('a', Currency.uzs));
    expect(container.read(agentCartProvider), hasLength(1), reason: 'adding an existing line keeps it');
    cart.remove('a');
    expect(container.read(agentCartProvider), isEmpty);
    cart
      ..add(_item('b', Currency.usd))
      ..clear();
    expect(cart.currency, isNull);
  });

  test('agentQty drops a whole number\'s decimals and trims fractions', () {
    expect(agentQty(12), '12');
    expect(agentQty(2.5), '2.5');
    expect(agentQty(0.125), '0.125');
  });
}
