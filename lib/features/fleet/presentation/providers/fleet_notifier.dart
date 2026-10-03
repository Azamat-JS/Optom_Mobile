import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/realtime/tracking_socket.dart';
import 'package:bsmart/features/fleet/domain/fleet_courier.dart';
import 'package:bsmart/features/fleet/domain/fleet_repository.dart';

/// Live fleet: REST snapshot, then the fleet room's events (the server joins
/// owner/admin sockets to it automatically). `location` moves a courier in
/// place; `presence` and `delivery:status` refetch (new names / delivery tags).
/// The screen holds the socket while open.
class FleetNotifier extends AutoDisposeAsyncNotifier<List<FleetCourier>> {
  Timer? _debounce;

  @override
  Future<List<FleetCourier>> build() async {
    final events = getIt<TrackingSocket>().events.listen((e) {
      switch (e.name) {
        case 'location':
          _onLocation(e.data);
        case 'presence' || 'delivery:status':
          _scheduleRefresh();
      }
    });
    ref.onDispose(() {
      events.cancel();
      _debounce?.cancel();
    });
    return _fetch();
  }

  Future<List<FleetCourier>> _fetch() async {
    final result = await getIt<GetFleetUseCase>().call();
    return result.fold((list) => list, (failure) => throw failure);
  }

  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), refresh);
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(_fetch);
    if (next.hasError && state.hasValue) return;
    state = next;
  }

  void _onLocation(Map<String, dynamic> d) {
    final list = state.valueOrNull;
    if (list == null) return;
    final id = d['subjectId'] as String?;
    final i = list.indexWhere((c) => c.id == id);
    if (i < 0) return _scheduleRefresh(); // someone we don't know yet came online
    final speed = (d['speed'] as num?)?.toDouble() ?? 0;
    final updated = [...list]
      ..[i] = list[i].moved(
        GeoPoint((d['lat'] as num).toDouble(), (d['lng'] as num).toDouble()),
        heading: speed > 1 ? (d['heading'] as num?)?.toDouble() : null,
        at: DateTime.now(),
      );
    state = AsyncData(updated);
  }
}

final fleetProvider = AsyncNotifierProvider.autoDispose<FleetNotifier, List<FleetCourier>>(FleetNotifier.new);
