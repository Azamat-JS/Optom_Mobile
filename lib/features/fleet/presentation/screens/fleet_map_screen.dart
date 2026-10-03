import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/maps/animated_position.dart';
import 'package:bsmart/core/maps/map_icons.dart';
import 'package:bsmart/core/realtime/tracking_socket.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/screens/delivery_tracking_screen.dart';
import 'package:bsmart/features/fleet/domain/fleet_courier.dart';
import 'package:bsmart/features/fleet/presentation/providers/fleet_notifier.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';

/// Owner/admin live map of their couriers. Green = online & free, brand
/// colour = on a delivery, grey = stale (no point for 60 s). Owners see the
/// whole business, store admins only their store (server-scoped).
class FleetMapScreen extends ConsumerStatefulWidget {
  const FleetMapScreen({super.key});

  @override
  ConsumerState<FleetMapScreen> createState() => _FleetMapScreenState();
}

class _FleetMapScreenState extends ConsumerState<FleetMapScreen> with TickerProviderStateMixin {
  static const _free = Color(0xFF2E7D32);
  static const _busy = Color(0xFF1565C0);
  static const _stale = Color(0xFF9E9E9E);

  final _socket = getIt<TrackingSocket>();
  final _positions = <String, AnimatedPosition>{};
  final _icons = <Color, BitmapDescriptor>{};
  GoogleMapController? _map;
  Timer? _tick;
  bool _fitted = false;

  @override
  void initState() {
    super.initState();
    _socket.hold(this);
    for (final c in [_free, _busy, _stale]) {
      MapIcons.courier(c).then((icon) {
        if (mounted) setState(() => _icons[c] = icon);
      });
    }
    _tick = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {}); // re-evaluate staleness
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _socket.release(this);
    for (final p in _positions.values) {
      p.dispose();
    }
    _map?.dispose();
    super.dispose();
  }

  /// Keeps one glide controller per courier and feeds it the latest position.
  void _sync(List<FleetCourier> fleet) {
    final ids = fleet.map((c) => c.id).toSet();
    for (final gone in _positions.keys.where((k) => !ids.contains(k)).toList()) {
      _positions.remove(gone)!.dispose();
    }
    for (final c in fleet) {
      final loc = c.location;
      if (loc == null) continue;
      final anim = _positions.putIfAbsent(c.id, () {
        // Shorter glide than the delivery maps: a marker re-rendering mid-glide drops taps on
        // Android, so keep it still most of the time between 2–3 s points.
        final a = AnimatedPosition(vsync: this, duration: const Duration(milliseconds: 800));
        a.addListener(() {
          if (mounted) setState(() {});
        });
        return a;
      });
      final target = LatLng(loc.lat, loc.lng);
      if (anim.value?.position != target) anim.moveTo(target, heading: c.heading);
    }
  }

  Future<void> _fit(List<FleetCourier> fleet) async {
    final pts = [
      for (final c in fleet)
        if (c.location != null) LatLng(c.location!.lat, c.location!.lng),
    ];
    final map = _map;
    if (map == null || pts.isEmpty) return;
    if (pts.length == 1) return map.animateCamera(CameraUpdate.newLatLngZoom(pts.first, 15));
    await map.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(pts.map((p) => p.latitude).reduce(math.min), pts.map((p) => p.longitude).reduce(math.min)),
          northeast: LatLng(pts.map((p) => p.latitude).reduce(math.max), pts.map((p) => p.longitude).reduce(math.max)),
        ),
        80,
      ),
    );
  }

  Color _colorOf(FleetCourier c, DateTime now) => c.isStale(now) ? _stale : (c.busy ? _busy : _free);

  @override
  Widget build(BuildContext context) {
    final fleet = ref.watch(fleetProvider);
    final list = fleet.valueOrNull ?? const <FleetCourier>[];
    _sync(list);
    final now = DateTime.now();
    final online = list.where((c) => !c.isStale(now)).length;
    final busy = list.where((c) => c.busy && !c.isStale(now)).length;
    if (!_fitted && _map != null && list.isNotEmpty) {
      _fitted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit(list));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuryerlar xaritasi'),
        actions: [
          IconButton(
            tooltip: 'Yangilash',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(fleetProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(41.3111, 69.2797), zoom: 12),
            onMapCreated: (c) => _map = c,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: {
              for (final c in list)
                if (_positions[c.id]?.value != null && _icons[_colorOf(c, now)] != null)
                  Marker(
                    markerId: MarkerId(c.id),
                    position: _positions[c.id]!.value!.position,
                    rotation: _positions[c.id]!.value!.bearing,
                    // Non-flat: flat (map-plane) markers with a centre anchor proved unreliable to
                    // tap; this map is never tilted/rotated, so screen-relative rotation is the same.
                    anchor: const Offset(0.5, 0.5),
                    consumeTapEvents: true,
                    icon: _icons[_colorOf(c, now)]!,
                    infoWindow: InfoWindow(title: c.name),
                    onTap: () => _showCourier(c),
                  ),
            },
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Wrap(
              spacing: 8,
              children: [
                _Chip(color: _free, text: '$online onlayn'),
                _Chip(color: _busy, text: '$busy yetkazishda'),
                if (list.length - online > 0) _Chip(color: _stale, text: '${list.length - online} aloqasiz'),
              ],
            ).animate().fadeIn(duration: AppMotion.standard),
          ),
          // Small moving markers are hard to hit on a phone — a strip of courier cards is the
          // reliable way in (tap → centre on the courier + details sheet).
          if (list.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final stale = c.isStale(now);
                    return Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surface,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          final at = _positions[c.id]?.value?.position;
                          if (at != null) _map?.animateCamera(CameraUpdate.newLatLngZoom(at, 15));
                          _showCourier(c);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: _colorOf(c, now),
                                child: const Icon(Icons.moped, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(
                                    stale ? "Aloqa yo'q" : (c.busy ? 'Yetkazishda' : "Bo'sh"),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate(delay: AppMotion.fast * 0.3 * i).fadeIn(duration: AppMotion.standard).slideY(begin: 0.3);
                  },
                ),
              ),
            ),
          if (fleet.isLoading && !fleet.hasValue) const Center(child: CircularProgressIndicator()),
          if (fleet.hasValue && list.isEmpty)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.moped_outlined, size: 40, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 8),
                      const Text("Hozircha onlayn kuryer yo'q"),
                    ],
                  ),
                ),
              ),
            ),
          if (fleet.hasError && !fleet.hasValue) Center(child: Text('Xatolik: ${fleet.error}')),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: list.isEmpty
          ? null
          : FloatingActionButton.small(
              heroTag: 'fleet-fit',
              tooltip: "Hammasini ko'rsatish",
              onPressed: () => _fit(list),
              child: const Icon(Icons.zoom_out_map),
            ),
    );
  }

  void _showCourier(FleetCourier c) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final now = DateTime.now();
        final stale = c.isStale(now);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _colorOf(c, now),
                      child: const Icon(Icons.moped, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            [
                              stale ? 'Aloqa yo\'q' : (c.busy ? 'Yetkazishda' : "Bo'sh"),
                              'oxirgi joylashuv ${trackingAgoLabel(c.lastPointAt, now)}',
                            ].join(' · '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (c.phone != null)
                      IconButton.filledTonal(
                        tooltip: "Qo'ng'iroq",
                        onPressed: () => DeliveryActions.call(context, c.phone),
                        icon: const Icon(Icons.call),
                      ),
                  ],
                ),
                for (final id in c.deliveryIds) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(
                          this.context,
                        ).push(MaterialPageRoute(builder: (_) => DeliveryTrackingScreen(deliveryId: id)));
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: Text(
                        c.deliveryIds.length > 1
                            ? 'Yetkazishni ko\'rish (${c.deliveryIds.indexOf(id) + 1})'
                            : 'Yetkazishni ko\'rish',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 2,
    borderRadius: BorderRadius.circular(20),
    color: Theme.of(context).colorScheme.surface,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}
