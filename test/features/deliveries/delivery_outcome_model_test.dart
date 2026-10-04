import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/features/deliveries/data/models/delivery_model.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/stores/data/models/store_model.dart';

// Phase 7 N2/N3: the new delivery outcome + handover fields, in both the staff and customer shapes
// the backend sends (Optom_Savdo CLAUDE.md "Delivery outcomes + handover code").
Map<String, dynamic> _base(Map<String, dynamic> extra) => {
      'id': 'd1',
      'status': 'PICKED_UP',
      'source': 'ORDER',
      'createdAt': '2026-10-04T10:00:00.000Z',
      ...extra,
    };

void main() {
  test('FAILED is a terminal status with a reason, note and outcome location (staff view)', () {
    final d = deliveryFromJson(_base({
      'status': 'FAILED',
      'failedAt': '2026-10-04T10:30:00.000Z',
      'failReason': 'NOT_HOME',
      'failNote': 'Eshik yopiq',
      'outcomeLocation': {'lat': 41.32, 'lng': 69.25, 'at': '2026-10-04T10:30:00.000Z', 'distanceToDropoffMeters': 42},
    }));
    expect(d.status, DeliveryStatus.failed);
    expect(d.status.isTerminal, isTrue);
    expect(d.status.isActive, isFalse);
    expect(d.failReason, DeliveryFailReason.notHome);
    expect(d.failNote, 'Eshik yopiq');
    expect(d.outcomeLocation?.distanceToDropoffMeters, 42);
    expect(d.outcomeLocation?.point.lat, 41.32);
  });

  test('staff/courier handover summary: pending, tries left, locked, waived — never a code', () {
    final pending = deliveryFromJson(_base({
      'handover': {'required': true, 'pending': true, 'attemptsLeft': 3, 'locked': false, 'waivedAt': null},
    }));
    expect(pending.handover.pending, isTrue);
    expect(pending.handover.attemptsLeft, 3);
    expect(pending.handover.code, isNull);

    final locked = deliveryFromJson(_base({
      'handover': {'required': true, 'pending': true, 'attemptsLeft': 0, 'locked': true},
    }));
    expect(locked.handover.locked, isTrue);

    final waived = deliveryFromJson(_base({
      'handover': {'required': true, 'pending': false, 'attemptsLeft': 0, 'locked': false, 'waivedAt': '2026-10-04T10:00:00Z'},
    }));
    expect(waived.handover.pending, isFalse);
    expect(waived.handover.waived, isTrue);
  });

  test('customer handover: a code means pending; null code means nothing to show', () {
    final c = deliveryFromJson(_base({'handover': {'required': true, 'code': '0427'}}));
    expect(c.handover.code, '0427');
    expect(c.handover.pending, isTrue);
    final none = deliveryFromJson(_base({'handover': {'required': true, 'code': null}}));
    expect(none.handover.pending, isFalse);
  });

  test('older payloads (no N2 fields) still parse', () {
    final d = deliveryFromJson(_base({}));
    expect(d.handover.required, isFalse);
    expect(d.failReason, isNull);
    expect(d.outcomeLocation, isNull);
    expect(DeliveryStatus.fromWire('SOMETHING_NEW'), DeliveryStatus.pending);
    expect(DeliveryFailReason.fromWire('NOPE'), isNull);
  });

  test('isWithCourier: only PICKED_UP / ARRIVED can be completed or failed', () {
    expect(
      DeliveryStatus.values.where((s) => s.isWithCourier),
      [DeliveryStatus.pickedUp, DeliveryStatus.arrived],
    );
  });

  test('store parses requireHandoverCode (default off)', () {
    final base = {'id': 's1', 'name': 'Lazzat', 'isActive': true, 'createdAt': '2026-10-04T10:00:00.000Z'};
    expect(storeFromJson(base).requireHandoverCode, isFalse);
    expect(storeFromJson({...base, 'requireHandoverCode': true}).requireHandoverCode, isTrue);
  });
}
