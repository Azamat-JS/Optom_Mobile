import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/usecases/get_order_delivery_usecase.dart';

/// The delivery attached to an order (null = none), for the order detail card.
final orderDeliveryProvider = FutureProvider.autoDispose.family<Delivery?, String>((ref, orderId) async {
  final result = await getIt<GetOrderDeliveryUseCase>().call(orderId);
  return result.fold((d) => d, (failure) => throw failure);
});
