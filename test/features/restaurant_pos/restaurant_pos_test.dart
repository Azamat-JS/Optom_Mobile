import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/restaurant_order_enums.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/features/restaurant_orders/data/models/restaurant_order_model.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order.dart';
import 'package:bsmart/features/restaurant_orders/domain/restaurant_order_status_actions.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_write_params.dart';
import 'package:bsmart/features/restaurant_orders/domain/entities/restaurant_order_item_input.dart';
import 'package:bsmart/features/restaurant_pos/presentation/providers/restaurant_pos_providers.dart';
import 'package:bsmart/features/restaurant_pos/presentation/widgets/pos_bill_card.dart';
import 'package:bsmart/features/restaurant_tables/domain/entities/restaurant_table.dart';
import 'package:bsmart/features/sales/domain/entities/sale_write_params.dart';
import 'package:bsmart/core/enums/sale_enums.dart';

Map<String, dynamic> _json({
  String id = 'o1',
  String type = 'DINE_IN',
  String status = 'NEW',
  String? tableId = 't1',
  bool isTakeaway = false,
  String? saleId,
  String createdAt = '2026-11-07T10:00:00.000Z',
  num subtotal = 85000,
  num servicePercent = 10,
  num waiterPercent = 0,
  String? waiterId,
  List<Map<String, dynamic>>? items,
}) => {
  'id': id,
  'orderNumber': 'RO-20261107-ABC123',
  'type': type,
  'status': status,
  'table': tableId == null ? null : {'id': tableId, 'name': '1-stol', 'percent': '$servicePercent'},
  'tableNumber': tableId == null ? null : '1-stol',
  'subtotal': '$subtotal',
  'discount': '0',
  'total': '$subtotal',
  'serviceChargePercent': '$servicePercent',
  'serviceChargeAmount': '0',
  'waiterCommissionPercent': '$waiterPercent',
  'waiterCommissionAmount': '0',
  'grandTotal': '${subtotal * (1 + (servicePercent + waiterPercent) / 100)}',
  'isTakeaway': isTakeaway,
  'saleId': saleId,
  'waiter': waiterId == null ? null : {'id': waiterId, 'firstName': 'Ali', 'lastName': 'Valiyev'},
  'kitchenHeld': isTakeaway,
  'items':
      items ??
      [
        {'id': 'i1', 'productId': 'p1', 'productName': 'Plov', 'quantity': 2, 'unitPrice': '40000', 'kitchenSentAt': '2026-11-07T10:00:00.000Z'},
        {'id': 'i2', 'productId': 'p2', 'productName': 'Choy', 'quantity': 1, 'unitPrice': '5000', 'kitchenSentAt': null},
      ],
  'createdAt': createdAt,
};

RestaurantOrder _order({
  String id = 'o1',
  String type = 'DINE_IN',
  String status = 'NEW',
  String? tableId = 't1',
  bool isTakeaway = false,
  String? saleId,
  String createdAt = '2026-11-07T10:00:00.000Z',
  num waiterPercent = 0,
  String? waiterId,
}) => restaurantOrderFromJson(
  _json(
    id: id,
    type: type,
    status: status,
    tableId: tableId,
    isTakeaway: isTakeaway,
    saleId: saleId,
    createdAt: createdAt,
    waiterPercent: waiterPercent,
    waiterId: waiterId,
  ),
);

const _t1 = RestaurantTable(id: 't1', name: '1-stol', percent: 10, storeId: 's');
const _t2 = RestaurantTable(id: 't2', name: '2-stol', percent: 0, storeId: 's');
const _t10 = RestaurantTable(id: 't10', name: '10-stol', percent: 0, storeId: 's');

void main() {
  group('order JSON', () {
    test('reads the takeaway flag, sale id, kitchen state', () {
      final o = _order(isTakeaway: true, tableId: null, saleId: 'sale1');
      expect(o.isTakeaway, isTrue);
      expect(o.saleId, 'sale1');
      expect(o.kitchenHeld, isTrue);
      expect(o.items[0].kitchenSent, isTrue);
      expect(o.items[1].kitchenSent, isFalse);
      expect(o.unitCount, 3);
    });

    test('older responses without the new fields still parse', () {
      final json = _json()..remove('isTakeaway')..remove('saleId')..remove('kitchenHeld');
      final o = restaurantOrderFromJson(json);
      expect(o.isTakeaway, isFalse);
      expect(o.saleId, isNull);
    });
  });

  group('table views', () {
    test('natural order, bills per table, others left out', () {
      final orders = [
        _order(id: 'a'),
        _order(id: 'b', createdAt: '2026-11-07T09:00:00.000Z'),
        _order(id: 'take', tableId: null, isTakeaway: true),
        _order(id: 'del', type: 'DELIVERY', tableId: null),
      ];
      final views = buildPosTableViews([_t10, _t2, _t1], orders);
      expect(views.map((v) => v.table.name), ['1-stol', '2-stol', '10-stol']);
      expect(views[0].orders.map((o) => o.id), ['b', 'a']);
      expect(views[1].occupied, isFalse);
      expect(otherPosOrders(orders).map((o) => o.id), ['take', 'del']);
    });

    test('state: free / open / ready / unpaid', () {
      PosTableState stateOf(List<String> statuses) => buildPosTableViews([_t1], [
        for (final (i, s) in statuses.indexed) _order(id: '$i', status: s),
      ]).single.state;
      expect(stateOf([]), PosTableState.free);
      expect(stateOf(['NEW']), PosTableState.open);
      expect(stateOf(['NEW', 'READY']), PosTableState.ready);
      expect(stateOf(['SERVED']), PosTableState.unpaid);
      expect(stateOf(['SERVED', 'PREPARING']), PosTableState.open);
    });

    test('dishes merge by name across bills', () {
      final view = buildPosTableViews([_t1], [_order(id: 'a'), _order(id: 'b')]).single;
      expect(view.dishes, [('Plov', 4), ('Choy', 2)]);
    });
  });

  group('editing', () {
    test('owner and admins add dishes to any order until paid; a waiter only to their own', () {
      final open = _order(waiterId: 'w1');
      expect(canAddItems(open, UserRole.retailer, 'owner'), isTrue);
      expect(canAddItems(open, UserRole.retailerAdmin, 'admin'), isTrue);
      expect(canAddItems(open, UserRole.waiter, 'w1'), isTrue);
      expect(canAddItems(open, UserRole.waiter, 'w2'), isFalse);
      expect(canAddItems(_order(), UserRole.waiter, 'w1'), isFalse);
      expect(canAddItems(_order(waiterId: 'w1', isTakeaway: true, tableId: null), UserRole.waiter, 'w1'), isFalse);
      expect(canAddItems(_order(waiterId: 'w1', saleId: 's'), UserRole.waiter, 'w1'), isFalse);
      expect(canAddItems(_order(status: 'SERVED'), UserRole.retailer, 'owner'), isTrue);
      expect(canAddItems(_order(saleId: 's'), UserRole.retailer, 'owner'), isFalse);
      expect(canAddItems(_order(status: 'CANCELLED'), UserRole.retailer, 'owner'), isFalse);
    });

    test('only the owner and admins cancel — the order or single dishes', () {
      final open = _order(waiterId: 'w1');
      expect(canRemoveItems(open, UserRole.retailer), isTrue);
      expect(canRemoveItems(open, UserRole.retailerAdmin), isTrue);
      expect(canRemoveItems(open, UserRole.waiter), isFalse);
      expect(canRemoveItems(_order(saleId: 's'), UserRole.retailer), isFalse);
      expect(getStatusActions(open, UserRole.retailer, 'owner'), contains(RestaurantOrderStatus.cancelled));
      expect(getStatusActions(open, UserRole.retailerAdmin, 'admin'), contains(RestaurantOrderStatus.cancelled));
      expect(getStatusActions(open, UserRole.waiter, 'w1'), isNot(contains(RestaurantOrderStatus.cancelled)));
      expect(getStatusActions(open, UserRole.waiter, 'w1'), [RestaurantOrderStatus.preparing]);
    });
  });

  group('payable', () {
    test('both percents on the discounted food total', () {
      final o = _order(waiterPercent: 5);
      expect(payableFor(o, 0), 85000 + 8500 + 4250);
      expect(payableFor(o, 5000), 80000 + 8000 + 4000);
      expect(payableFor(o, 0, service: false), 85000 + 4250);
      expect(payableFor(o, 999999), 0);
    });
  });

  group('request bodies', () {
    test('a takeaway order', () {
      final body = const CreateRestaurantOrderParams(
        type: RestaurantOrderType.dineIn,
        takeaway: true,
        items: [RestaurantOrderItemInput(productId: 'p1', quantity: 2)],
      ).toRequestBody();
      expect(body['takeaway'], isTrue);
      expect(body.containsKey('tableId'), isFalse);
    });

    test('a sale paying a restaurant order with a service line', () {
      final body = const CreateSaleParams(
        customerId: 'c',
        type: SaleType.paid,
        restaurantOrderId: 'o1',
        items: [
          CreateSaleItemParams(productId: 'p1', quantity: 2, unitPrice: 40000),
          CreateSaleItemParams(productName: 'Xizmat haqi (10%)', quantity: 1, unitPrice: 8500, costPrice: 0),
        ],
      ).toRequestBody();
      expect(body['restaurantOrderId'], 'o1');
      final items = body['items'] as List;
      expect((items[1] as Map)['costPrice'], 0);
      expect((items[0] as Map).containsKey('costPrice'), isFalse);
    });
  });
}
