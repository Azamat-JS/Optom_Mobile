import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/realtime/tracking_socket.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:bsmart/features/deliveries/domain/usecases/advance_delivery_usecase.dart';
import 'package:bsmart/features/deliveries/domain/usecases/list_deliveries_usecase.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';

/// The courier's open deliveries: their accepted ones plus open offers.
///
/// Refreshes on every `delivery:status` socket event (pushed to the courier's
/// own room while online) and every 30 s as a fallback while offline. Each
/// fetch also tells [TrackingNotifier] which deliveries are active, so the
/// tracking notification and "who sees me" text stay truthful.
class CourierDeliveriesNotifier extends AsyncNotifier<List<Delivery>> {
  @override
  Future<List<Delivery>> build() async {
    // Rebuild from scratch whenever the signed-in account changes — this provider is app-global,
    // so without this a second courier on the same phone would briefly see the first one's list.
    final userId = ref.watch(sessionNotifierProvider.select((s) => s.valueOrNull?.session?.userId));
    if (userId == null) return const [];
    final events = getIt<TrackingSocket>().events.where((e) => e.name == 'delivery:status').listen((_) => refresh());
    final poll = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
    ref.onDispose(() {
      events.cancel();
      poll.cancel();
    });
    return _fetch();
  }

  Future<List<Delivery>> _fetch() async {
    final result = await getIt<ListDeliveriesUseCase>().call(openOnly: true);
    final items = result.fold((list) => list, (failure) => throw failure);
    _syncTrackingContext(items);
    return items;
  }

  void _syncTrackingContext(List<Delivery> items) {
    final active = items.where((d) => d.status.isActive).toList();
    ref.read(trackingNotifierProvider.notifier).setActiveDelivery(
          active.isEmpty ? null : (active.length == 1 ? active.first.label : '${active.length} ta yetkazish'),
          customerWatches: active.any((d) => d.source == DeliverySource.order),
        );
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(_fetch);
    // Keep showing the previous list if a background refresh fails.
    if (next.hasError && state.hasValue) return;
    state = next;
  }

  /// Runs a courier step; returns the failure (for a SnackBar) or null.
  Future<ApiException?> advance(String id, DeliveryAction action) async {
    final result = await getIt<AdvanceDeliveryUseCase>().call(id, action);
    await refresh();
    return result.fold((_) => null, (failure) => failure);
  }
}

final courierDeliveriesProvider = AsyncNotifierProvider<CourierDeliveriesNotifier, List<Delivery>>(
  CourierDeliveriesNotifier.new,
);
