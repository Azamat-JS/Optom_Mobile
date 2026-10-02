import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/maps/animated_position.dart';
import 'package:bsmart/core/maps/map_icons.dart';
import 'package:bsmart/core/maps/polyline_codec.dart';
import 'package:bsmart/core/realtime/tracking_socket.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/providers/delivery_detail_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/providers/delivery_route_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/order_delivery_card.dart';

/// "Where is my courier?" — the viewer's live map of one delivery (customer,
/// and equally usable by owner/admin staff).
///
/// Holds the tracking socket while open; [deliveryRouteProvider] subscribes to
/// the delivery room, which streams `delivery:location` (the courier marker
/// glides between points), `delivery:route` (road route + ETA) and
/// `delivery:status`. The server only streams while the delivery is active.
class DeliveryTrackingScreen extends ConsumerStatefulWidget {
  const DeliveryTrackingScreen({super.key, required this.deliveryId});

  final String deliveryId;

  @override
  ConsumerState<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends ConsumerState<DeliveryTrackingScreen> with TickerProviderStateMixin {
  static const _staleAfter = Duration(seconds: 60);

  late final _courier = AnimatedPosition(vsync: this);
  final _socket = getIt<TrackingSocket>();
  StreamSubscription<TrackingSocketEvent>? _events;
  GoogleMapController? _map;
  BitmapDescriptor? _courierIcon;
  DateTime? _lastPointAt;
  Timer? _tick;
  bool _fitted = false;
  String? _decodedFor;
  List<LatLng> _routePoints = const [];

  @override
  void initState() {
    super.initState();
    _socket.hold(this);
    _events = _socket.events
        .where((e) => e.name == 'delivery:location' && e.data['deliveryId'] == widget.deliveryId)
        .listen((e) {
      final speed = (e.data['speed'] as num?)?.toDouble() ?? 0;
      _courier.moveTo(
        LatLng((e.data['lat'] as num).toDouble(), (e.data['lng'] as num).toDouble()),
        heading: speed > 1 ? (e.data['heading'] as num?)?.toDouble() : null,
      );
      final first = _lastPointAt == null;
      setState(() => _lastPointAt = DateTime.now());
      if (first) _fit();
    });
    _tick = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {}); // ETA countdown + stale check
    });
    MapIcons.courier(const Color(0xFF1565C0)).then((icon) {
      if (mounted) setState(() => _courierIcon = icon);
    });
  }

  @override
  void dispose() {
    _events?.cancel();
    _tick?.cancel();
    _socket.release(this);
    _courier.dispose();
    _map?.dispose();
    super.dispose();
  }

  LatLng _ll(LatLngPoint p) => LatLng(p.lat, p.lng);

  Future<void> _fit() async {
    final d = ref.read(deliveryDetailProvider(widget.deliveryId)).valueOrNull;
    final map = _map;
    if (d == null || map == null) return;
    final pts = [
      if (d.dropoff != null) _ll(d.dropoff!),
      if (_courier.value != null) _courier.value!.position,
      if (_courier.value == null && d.pickup != null) _ll(d.pickup!),
    ];
    if (pts.isEmpty) return;
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

  @override
  Widget build(BuildContext context) {
    final delivery = ref.watch(deliveryDetailProvider(widget.deliveryId));
    final route = ref.watch(deliveryRouteProvider(widget.deliveryId)).valueOrNull;
    if (route != null && route.encodedPolyline != _decodedFor) {
      _decodedFor = route.encodedPolyline;
      _routePoints = decodePolyline(route.encodedPolyline);
      // Before the first live point, place the courier where the route was computed from.
      if (_courier.value == null && route.fromCourier) {
        _courier.moveTo(_ll(route.origin));
        WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(delivery.valueOrNull?.label ?? 'Yetkazish')),
      body: delivery.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xatolik: $e')),
        data: (d) => Stack(
          children: [
            Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: _courier,
                builder: (context, me, _) => GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: d.dropoff != null ? _ll(d.dropoff!) : const LatLng(41.3111, 69.2797),
                    zoom: 14,
                  ),
                  onMapCreated: (c) {
                    _map = c;
                    if (!_fitted) {
                      _fitted = true;
                      Future.delayed(AppMotion.standard, _fit);
                    }
                  },
                  padding: const EdgeInsets.only(bottom: 220),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  markers: {
                    if (d.dropoff != null)
                      Marker(
                        markerId: const MarkerId('dropoff'),
                        position: _ll(d.dropoff!),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                        infoWindow: const InfoWindow(title: 'Yetkazib berish manzili'),
                      ),
                    // The store only matters until the courier has picked the order up.
                    if (d.pickup != null && (d.status.isOffer || d.status == DeliveryStatus.accepted))
                      Marker(
                        markerId: const MarkerId('pickup'),
                        position: _ll(d.pickup!),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                        infoWindow: const InfoWindow(title: "Do'kon"),
                      ),
                    if (me != null && _courierIcon != null && d.status.isActive)
                      Marker(
                        markerId: const MarkerId('courier'),
                        position: me.position,
                        icon: _courierIcon!,
                        flat: true,
                        anchor: const Offset(0.5, 0.5),
                        rotation: me.bearing,
                        zIndexInt: 2,
                      ),
                  },
                  polylines: {
                    if (route != null && _routePoints.length > 1 && d.status.isActive) ...[
                      Polyline(polylineId: const PolylineId('casing'), points: _routePoints, color: Colors.white, width: 9),
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: _routePoints,
                        color: const Color(0xFF1565C0),
                        width: 5,
                        zIndex: 1,
                      ),
                    ],
                  },
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 232,
              child: FloatingActionButton.small(
                heroTag: 'fit',
                tooltip: "Hammasini ko'rsatish",
                onPressed: _fit,
                child: const Icon(Icons.zoom_out_map),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _InfoPanel(delivery: d, route: route, lastPointAt: _lastPointAt)
                  .animate()
                  .slideY(begin: 0.3, duration: AppMotion.standard, curve: AppMotion.emphasized)
                  .fadeIn(duration: AppMotion.standard),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.delivery, required this.route, required this.lastPointAt});

  final Delivery delivery;
  final DeliveryRoute? route;
  final DateTime? lastPointAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = delivery;
    final now = DateTime.now();
    final eta = d.status.isActive && d.status != DeliveryStatus.arrived ? route?.remaining(RouteStopKind.dropoff, now) : null;
    final stale = d.status.isActive &&
        (lastPointAt == null || now.difference(lastPointAt!) > _DeliveryTrackingScreenState._staleAfter);

    return Material(
      elevation: 12,
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(OrderDeliveryCard.headline(d.status), style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: AppMotion.standard,
                child: eta != null
                    ? Text(
                        '~${(eta.inSeconds / 60).ceil()} daqiqada yetib keladi',
                        key: ValueKey(eta.inMinutes),
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                      )
                    : const SizedBox.shrink(),
              ),
              if (stale) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Text('Kuryer joylashuvi yangilanmoqda…', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
              const Divider(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.delivery_dining, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.courier?.firstName ?? 'Kuryer', style: theme.textTheme.titleMedium),
                        Text('Sizning kuryeringiz', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (d.courier?.phone != null && !d.status.isTerminal)
                    FilledButton.tonalIcon(
                      onPressed: () => DeliveryActions.call(context, d.courier!.phone),
                      icon: const Icon(Icons.call),
                      label: const Text("Qo'ng'iroq"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
