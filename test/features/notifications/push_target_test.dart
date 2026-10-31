import 'package:flutter_test/flutter_test.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/features/notifications/presentation/push/push_target.dart';

void main() {
  const staff = {'notificationId': 'n1', 'type': 'CRM_SERVICE_DUE', 'audience': 'staff', 'driverId': 'drv1'};

  test('a staff reminder opens the driver for a retailer owner or admin', () {
    expect(pushTargetRoute(staff, UserRole.retailer), RouteNames.crmDriverDetail('drv1'));
    expect(pushTargetRoute(staff, UserRole.retailerAdmin), RouteNames.crmDriverDetail('drv1'));
  });

  test('anyone else, a driver reminder, or unknown data opens the inbox', () {
    expect(pushTargetRoute(staff, UserRole.customer), RouteNames.notifications);
    expect(pushTargetRoute({...staff, 'audience': 'driver'}, UserRole.retailer), RouteNames.notifications);
    expect(pushTargetRoute({...staff, 'driverId': ''}, UserRole.retailer), RouteNames.notifications);
    expect(pushTargetRoute(const {'type': 'SOMETHING_NEW'}, UserRole.retailer), RouteNames.notifications);
    expect(pushTargetRoute(staff, null), RouteNames.notifications);
  });
}
