import 'package:bsmart/features/sales/domain/entities/sale.dart';
import 'package:bsmart/l10n/app_localizations.dart';

/// The name to show for a sale's customer: the walk-in customer in the app's language
/// (it is stored as the Uzbek "Mehmon xaridor"), anyone else by their own name.
String saleCustomerName(SalePersonRef customer, AppLocalizations l10n) =>
    customer.isWalkIn ? l10n.rposWalkInCustomer : customer.fullName;
