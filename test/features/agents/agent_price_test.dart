import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/features/agents/presentation/widgets/agent_format.dart';

// Mirrors Optom_Savdo's `agentPriceRange` (agent/agent-price.ts): price less at most the discount.
void main() {
  test('agents sell between the price less the discount and the price', () {
    expect(agentPriceRange(50000, 10), (min: 45000.0, max: 50000.0));
    expect(agentPriceRange(12500, 0), (min: 12500.0, max: 12500.0));
    expect(agentPriceRange(33333, 10).min, 29999.7);
    expect(agentPriceRange(19.99, 12.5).min, 17.49);
  });

  test('discount is 0–100 % with at most two decimals', () {
    expect(agentDiscountValid(0), isTrue);
    expect(agentDiscountValid(12.5), isTrue);
    expect(agentDiscountValid(0.29), isTrue);
    expect(agentDiscountValid(100), isTrue);
    expect(agentDiscountValid(-1), isFalse);
    expect(agentDiscountValid(100.5), isFalse);
    expect(agentDiscountValid(10.125), isFalse);
  });
}
