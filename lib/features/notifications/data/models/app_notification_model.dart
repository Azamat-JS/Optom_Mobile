import 'package:bsmart/features/notifications/domain/entities/app_notification.dart';

// `GET /notifications` rows (`notification.service.ts` SELECT) and the CRM_SERVICE_DUE `data`
// shape (`CrmServiceDueData` in `crm-alert.service.ts`).

AppNotification appNotificationFromJson(Map<String, dynamic> json) {
  final type = json['type'] as String;
  final data = json['data'];
  return AppNotification(
    id: json['id'] as String,
    type: type,
    readAt: json['readAt'] == null ? null : DateTime.parse(json['readAt'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    serviceDue: type == 'CRM_SERVICE_DUE' && data is Map<String, dynamic> ? _serviceDue(data) : null,
  );
}

CrmServiceDue _serviceDue(Map<String, dynamic> d) => CrmServiceDue(
      forDriver: d['audience'] == 'driver',
      storeName: d['storeName'] as String? ?? '',
      driverId: d['driverId'] as String? ?? '',
      driverName: d['driverName'] as String? ?? '',
      driverPhone: d['driverPhone'] as String? ?? '',
      plate: d['plate'] as String? ?? '',
      model: d['model'] as String? ?? '',
      items: [
        for (final i in (d['items'] as List? ?? const []))
          (
            name: (i as Map<String, dynamic>)['name'] as String,
            // "2026-12-11": a calendar day, kept at UTC midnight.
            dueDate: DateTime.parse('${i['dueDate']}T00:00:00Z'),
          ),
      ],
      driverNotified: d['driverNotified'] as bool?,
    );

NotificationPage notificationPageFromJson(Map<String, dynamic> json) {
  final meta = json['meta'] as Map<String, dynamic>;
  return NotificationPage(
    items: [for (final n in (json['data'] as List)) appNotificationFromJson(n as Map<String, dynamic>)],
    hasNext: meta['hasNext'] as bool? ?? false,
    unread: (meta['unread'] as num?)?.toInt() ?? 0,
  );
}
