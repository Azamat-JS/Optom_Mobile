import 'package:bsmart/core/enums/order_status.dart';

/// Mirrors `OrderQueryDto`. [view] only matters for a RETAILER, who plays
/// both sides of the order graph: `null`/`'outgoing'` (the default) means
/// their own B2B orders to a wholesaler (`buyerId` scoping); `'incoming'`
/// switches to B2C orders placed by a CUSTOMER against their storefront
/// (`sellerId` scoping) — see `order.service.ts findAll()`'s explicit
/// `view === 'incoming'` branch, confirmed against the real backend source.
/// SELLER/CUSTOMER/WAITER/COURIER never send this field; the backend ignores
/// it for them regardless (`TenantFilter.order()`'s default per-role scoping
/// already picks the only list that makes sense for those roles).
class OrderQuery {
  const OrderQuery({this.page = 1, this.limit = 20, this.status, this.search, this.view});

  final int page;
  final int limit;
  final OrderStatus? status;
  final String? search;
  final String? view;

  OrderQuery copyWith({
    int? page,
    OrderStatus? status,
    bool clearStatus = false,
    String? search,
    String? view,
    bool clearView = false,
  }) {
    return OrderQuery(
      page: page ?? this.page,
      limit: limit,
      status: clearStatus ? null : (status ?? this.status),
      search: search ?? this.search,
      view: clearView ? null : (view ?? this.view),
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status!.toWire(),
        if (search != null && search!.isNotEmpty) 'search': search,
        if (view != null) 'view': view,
      };
}
