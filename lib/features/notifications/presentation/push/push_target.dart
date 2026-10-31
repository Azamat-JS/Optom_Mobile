import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/router/route_names.dart';

/// Where a tapped push opens (pure — unit tested). Same rule as the inbox screen: a staff CRM
/// reminder takes a retailer owner/admin to the driver; everything else opens the inbox.
String pushTargetRoute(Map<String, dynamic> data, UserRole? role) {
  final driverId = data['driverId'];
  final canOpenDriver = role == UserRole.retailer || role == UserRole.retailerAdmin;
  if (data['type'] == 'CRM_SERVICE_DUE' &&
      data['audience'] == 'staff' &&
      driverId is String &&
      driverId.isNotEmpty &&
      canOpenDriver) {
    return RouteNames.crmDriverDetail(driverId);
  }
  return RouteNames.notifications;
}
