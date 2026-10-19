import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/order_status.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/orders/domain/entities/order.dart';
import 'package:bsmart/features/storefront/presentation/screens/customer_order_screen.dart';

Order _order(OrderStatus status) => Order(
  id: 'o1',
  orderNumber: 'ORD-1',
  status: status,
  currency: Currency.uzs,
  subtotal: 1000,
  discount: 0,
  total: 1000,
  paid: 0,
  balance: 1000,
  createdAt: DateTime(2026, 10, 19),
);

Delivery _delivery(DeliveryStatus status) =>
    Delivery(id: 'd1', status: status, source: DeliverySource.order, createdAt: DateTime(2026, 10, 19));

void main() {
  test('order status alone', () {
    expect(customerOrderStage(_order(OrderStatus.newOrder), null), CustomerOrderStage.placed);
    expect(customerOrderStage(_order(OrderStatus.approved), null), CustomerOrderStage.approved);
    expect(customerOrderStage(_order(OrderStatus.delivered), null), CustomerOrderStage.delivered);
    expect(customerOrderStage(_order(OrderStatus.rejected), null), CustomerOrderStage.rejected);
  });

  test('courier delivery moves an approved order along', () {
    final approved = _order(OrderStatus.approved);
    expect(customerOrderStage(approved, _delivery(DeliveryStatus.pending)), CustomerOrderStage.approved);
    expect(customerOrderStage(approved, _delivery(DeliveryStatus.accepted)), CustomerOrderStage.approved);
    expect(customerOrderStage(approved, _delivery(DeliveryStatus.pickedUp)), CustomerOrderStage.onTheWay);
    expect(customerOrderStage(approved, _delivery(DeliveryStatus.arrived)), CustomerOrderStage.onTheWay);
    expect(customerOrderStage(approved, _delivery(DeliveryStatus.delivered)), CustomerOrderStage.delivered);
    expect(customerOrderStage(approved, _delivery(DeliveryStatus.failed)), CustomerOrderStage.approved);
  });

  test('rejected wins over anything', () {
    expect(
      customerOrderStage(_order(OrderStatus.rejected), _delivery(DeliveryStatus.pickedUp)),
      CustomerOrderStage.rejected,
    );
  });
}
