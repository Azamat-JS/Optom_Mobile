import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/realtime/tracking_socket.dart';
import 'package:bsmart/features/deliveries/data/models/delivery_route_model.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';
import 'package:bsmart/features/deliveries/domain/usecases/get_delivery_route_usecase.dart';

/// Live road route + ETA for one delivery while a screen shows it.
///
/// Subscribing to the delivery's socket room is what makes the backend's
/// viewer-gated ETA loop run (routes are only recomputed while someone
/// watches — they're billed per request). Initial value via REST; then every
/// `delivery:route` push; status changes trigger a re-fetch. Null = routing
/// unavailable (screens fall back to a straight guide line).
class DeliveryRouteNotifier extends AutoDisposeFamilyAsyncNotifier<DeliveryRoute?, String> {
  @override
  Future<DeliveryRoute?> build(String id) async {
    final socket = getIt<TrackingSocket>();
    unawaited(socket.subscribe('delivery', id));
    final events = socket.events.where((e) => e.data['deliveryId'] == id).listen((e) {
      if (e.name == 'delivery:route') {
        state = AsyncData(deliveryRouteFromJson(e.data));
      } else if (e.name == 'delivery:status') {
        refresh();
      }
    });
    ref.onDispose(() {
      events.cancel();
      socket.unsubscribe('delivery', id);
    });
    return _fetch(id);
  }

  Future<DeliveryRoute?> _fetch(String id) async {
    final result = await getIt<GetDeliveryRouteUseCase>().call(id);
    return result.fold((r) => r, (failure) => throw failure);
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(() => _fetch(arg));
    if (next.hasError && state.hasValue) return;
    state = next;
  }
}

final deliveryRouteProvider =
    AsyncNotifierProvider.autoDispose.family<DeliveryRouteNotifier, DeliveryRoute?, String>(DeliveryRouteNotifier.new);
