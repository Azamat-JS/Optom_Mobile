import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/realtime/tracking_socket.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:bsmart/features/deliveries/domain/usecases/get_delivery_usecase.dart';
import 'package:bsmart/features/deliveries/presentation/providers/courier_deliveries_notifier.dart';

/// One delivery, kept fresh by `delivery:status` events for its id.
class DeliveryDetailNotifier extends AutoDisposeFamilyAsyncNotifier<Delivery, String> {
  @override
  Future<Delivery> build(String id) async {
    final events = getIt<TrackingSocket>()
        .events
        .where((e) => e.name == 'delivery:status' && e.data['deliveryId'] == id)
        .listen((_) => refresh());
    ref.onDispose(events.cancel);
    return _fetch(id);
  }

  Future<Delivery> _fetch(String id) async {
    final result = await getIt<GetDeliveryUseCase>().call(id);
    return result.fold((d) => d, (failure) => throw failure);
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(() => _fetch(arg));
    if (next.hasError && state.hasValue) return;
    state = next;
  }

  /// Runs a courier step through the list notifier (so the list and the
  /// tracking context update too) and refreshes this delivery.
  Future<ApiException?> advance(DeliveryAction action) async {
    final failure = await ref.read(courierDeliveriesProvider.notifier).advance(arg, action);
    await refresh();
    return failure;
  }
}

final deliveryDetailProvider =
    AsyncNotifierProvider.autoDispose.family<DeliveryDetailNotifier, Delivery, String>(DeliveryDetailNotifier.new);
