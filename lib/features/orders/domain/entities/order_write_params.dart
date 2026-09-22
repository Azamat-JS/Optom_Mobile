import 'package:bsmart/core/enums/order_status.dart';

/// Mirrors `OrderItemDto`.
class CreateOrderItemParams {
  const CreateOrderItemParams({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.discount,
  });

  final String productId;
  final double quantity;
  final double unitPrice;
  final double? discount;

  Map<String, dynamic> toRequestBody() => {
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (discount != null) 'discount': discount,
      };
}

/// Mirrors `CreateOrderDto`.
class CreateOrderParams {
  const CreateOrderParams({
    required this.sellerId,
    required this.items,
    this.notes,
    this.deliveryAddress,
  });

  final String sellerId;
  final List<CreateOrderItemParams> items;
  final String? notes;
  final String? deliveryAddress;

  Map<String, dynamic> toRequestBody() => {
        'sellerId': sellerId,
        'items': items.map((e) => e.toRequestBody()).toList(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        if (deliveryAddress != null && deliveryAddress!.isNotEmpty) 'deliveryAddress': deliveryAddress,
      };
}

/// Mirrors `UpdateOrderStatusDto`. [status] must be one of
/// APPROVED/REJECTED/DELIVERED — enforced by [Order.canApproveOrReject]/
/// [Order.canMarkDelivered] client-side, and by `VALID_TRANSITIONS`
/// server-side regardless.
class UpdateOrderStatusParams {
  const UpdateOrderStatusParams({required this.status, this.comment, this.rejectionReason});

  final OrderStatus status;
  final String? comment;
  final String? rejectionReason;

  Map<String, dynamic> toRequestBody() => {
        'status': status.toWire(),
        if (comment != null && comment!.isNotEmpty) 'comment': comment,
        if (rejectionReason != null && rejectionReason!.isNotEmpty) 'rejectionReason': rejectionReason,
      };
}
