import 'package:bsmart/core/enums/order_status.dart';

/// Mirrors `OrderQueryDto`. [view] is deliberately not exposed by any
/// Milestone 3 screen — it only matters for a RETAILER's incoming B2C
/// customer orders, which is Phase 2 (CUSTOMER/storefront) scope. Omitting
/// it means: SELLER sees incoming B2B orders, RETAILER sees their own
/// outgoing B2B orders (see `TenantFilter.order` — confirmed against the
/// real backend source, not assumed).
class OrderQuery {
  const OrderQuery({this.page = 1, this.limit = 20, this.status, this.search});

  final int page;
  final int limit;
  final OrderStatus? status;
  final String? search;

  OrderQuery copyWith({int? page, OrderStatus? status, bool clearStatus = false, String? search}) {
    return OrderQuery(
      page: page ?? this.page,
      limit: limit,
      status: clearStatus ? null : (status ?? this.status),
      search: search ?? this.search,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status!.toWire(),
        if (search != null && search!.isNotEmpty) 'search': search,
      };
}
