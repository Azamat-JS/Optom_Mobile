/// One entry of the in-app inbox (`GET /notifications`, Optom_Savdo CLAUDE.md "CRM" → C5). The
/// server stores no text: [type] says how to read the data, and the app writes the sentence in its
/// own language.
class AppNotification {
  const AppNotification({required this.id, required this.type, this.readAt, required this.createdAt, this.serviceDue});

  final String id;

  /// Wire type ("CRM_SERVICE_DUE"); unknown future types still list, without a body.
  final String type;
  final DateTime? readAt;
  final DateTime createdAt;

  /// Set for `CRM_SERVICE_DUE`.
  final CrmServiceDue? serviceDue;

  bool get isRead => readAt != null;

  AppNotification markedRead(DateTime at) =>
      AppNotification(id: id, type: type, readAt: readAt ?? at, createdAt: createdAt, serviceDue: serviceDue);
}

/// `data` of a CRM_SERVICE_DUE notification: a car's parts due within a few days.
class CrmServiceDue {
  const CrmServiceDue({
    required this.forDriver,
    required this.storeName,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.plate,
    required this.model,
    required this.items,
    this.driverNotified,
  });

  /// true: written to the driver; false: to the owner/admins.
  final bool forDriver;
  final String storeName;
  final String driverId;
  final String driverName;
  final String driverPhone;

  /// Already formatted ("01 A 123 BC").
  final String plate;
  final String model;
  final List<({String name, DateTime dueDate})> items;

  /// Staff only: whether the driver was reminded on Telegram.
  final bool? driverNotified;
}

class NotificationPage {
  const NotificationPage({required this.items, required this.hasNext, required this.unread});

  final List<AppNotification> items;
  final bool hasNext;
  final int unread;
}
