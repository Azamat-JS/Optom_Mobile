import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bsmart/core/location/location_fix.dart';
import 'package:bsmart/core/maps/animated_position.dart';
import 'package:bsmart/core/maps/map_icons.dart';
import 'package:bsmart/core/maps/polyline_codec.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/providers/delivery_detail_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/providers/delivery_route_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_pill.dart';

/// The courier's own delivery map: pickup + drop-off pins, their own
/// smoothly-moving position (from the live GPS stream), a guide line to the
/// next stop, and the step buttons.
///
/// The road route + per-stop ETA come from [deliveryRouteProvider] (T6); the
/// dashed straight guide line is only the fallback when routing is unavailable.
class CourierDeliveryScreen extends ConsumerStatefulWidget {
  const CourierDeliveryScreen({super.key, required this.deliveryId});

  final String deliveryId;

  @override
  ConsumerState<CourierDeliveryScreen> createState() => _CourierDeliveryScreenState();
}

class _CourierDeliveryScreenState extends ConsumerState<CourierDeliveryScreen> with TickerProviderStateMixin {
  static const _tashkent = LatLng(41.3111, 69.2797);

  late final _courier = AnimatedPosition(vsync: this);
  StreamSubscription<LocationFix>? _fixes;
  GoogleMapController? _map;
  BitmapDescriptor? _courierIcon;
  bool _fitted = false;
  bool _busy = false;
  Timer? _tick;
  // Decoding is cheap but the map rebuilds every animation frame — cache per polyline.
  String? _decodedFor;
  List<LatLng> _routePoints = const [];

  @override
  void initState() {
    super.initState();
    final tracking = ref.read(trackingNotifierProvider.notifier);
    final last = tracking.lastFix;
    if (last != null) _courier.moveTo(LatLng(last.lat, last.lng), heading: last.heading);
    _fixes = tracking.fixes.listen((f) => _courier.moveTo(LatLng(f.lat, f.lng), heading: (f.speed ?? 0) > 1 ? f.heading : null));
    // Re-renders the ETA countdown between server updates.
    _tick = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
    MapIcons.courier(const Color(0xFF1D6E4F)).then((icon) {
      if (mounted) setState(() => _courierIcon = icon);
    });
  }

  @override
  void dispose() {
    _fixes?.cancel();
    _tick?.cancel();
    _courier.dispose();
    _map?.dispose();
    super.dispose();
  }

  LatLng _ll(LatLngPoint p) => LatLng(p.lat, p.lng);

  List<LatLng> _points(Delivery d) => [
        if (d.pickup != null) _ll(d.pickup!),
        if (d.dropoff != null) _ll(d.dropoff!),
        if (_courier.value != null) _courier.value!.position,
      ];

  Future<void> _fitAll(Delivery d) async {
    final pts = _points(d);
    final map = _map;
    if (map == null || pts.isEmpty) return;
    if (pts.length == 1) return map.animateCamera(CameraUpdate.newLatLngZoom(pts.first, 15));
    final bounds = LatLngBounds(
      southwest: LatLng(pts.map((p) => p.latitude).reduce(math.min), pts.map((p) => p.longitude).reduce(math.min)),
      northeast: LatLng(pts.map((p) => p.latitude).reduce(math.max), pts.map((p) => p.longitude).reduce(math.max)),
    );
    await map.animateCamera(CameraUpdate.newLatLngBounds(bounds, 72));
  }

  Future<void> _run(DeliveryAction action) async {
    setState(() => _busy = true);
    final failure = await ref.read(deliveryDetailProvider(widget.deliveryId).notifier).advance(action);
    if (!mounted) return;
    setState(() => _busy = false);
    if (failure != null) {
      DeliveryActions.showError(context, failure.message);
    } else if (action == DeliveryAction.complete) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yetkazish yakunlandi')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final delivery = ref.watch(deliveryDetailProvider(widget.deliveryId));
    final route = ref.watch(deliveryRouteProvider(widget.deliveryId)).valueOrNull;
    if (route != null && route.encodedPolyline != _decodedFor) {
      _decodedFor = route.encodedPolyline;
      _routePoints = decodePolyline(route.encodedPolyline);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(delivery.valueOrNull?.label ?? 'Yetkazish'),
        actions: const [TrackingStatusPill()],
      ),
      body: delivery.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Xatolik: $e')),
        data: (d) {
          if (!_fitted && _map != null) {
            _fitted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll(d));
          }
          return Stack(
            children: [
              Positioned.fill(child: _buildMap(d, route)),
              Positioned(top: 12, left: 12, right: 12, child: _OfflineBanner(delivery: d)),
              Positioned(
                right: 12,
                bottom: 12 + _BottomPanel.estimatedHeight,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'fit',
                      tooltip: "Hammasini ko'rsatish",
                      onPressed: () => _fitAll(d),
                      child: const Icon(Icons.zoom_out_map),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'me',
                      tooltip: 'Mening joylashuvim',
                      onPressed: () {
                        final me = _courier.value;
                        if (me != null) _map?.animateCamera(CameraUpdate.newLatLngZoom(me.position, 16));
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomPanel(delivery: d, route: route, busy: _busy, onAction: _run)
                    .animate()
                    .slideY(begin: 0.3, duration: AppMotion.standard, curve: AppMotion.emphasized)
                    .fadeIn(duration: AppMotion.standard),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(Delivery d, DeliveryRoute? route) {
    final initial = d.pickup ?? d.dropoff;
    return ValueListenableBuilder(
      valueListenable: _courier,
      builder: (context, me, _) {
        final next = d.nextStop;
        return GoogleMap(
          initialCameraPosition: CameraPosition(target: initial != null ? _ll(initial) : (me?.position ?? _tashkent), zoom: 13),
          onMapCreated: (c) {
            _map = c;
            if (!_fitted) {
              _fitted = true;
              Future.delayed(AppMotion.standard, () => _fitAll(d));
            }
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          // Top inset leaves room for the offline banner so fit-to-bounds never hides a pin under it.
          padding: const EdgeInsets.only(top: 88, bottom: _BottomPanel.estimatedHeight),
          markers: {
            if (d.pickup != null)
              Marker(
                markerId: const MarkerId('pickup'),
                position: _ll(d.pickup!),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                infoWindow: InfoWindow(title: 'Olib ketish', snippet: d.storeName),
              ),
            if (d.dropoff != null)
              Marker(
                markerId: const MarkerId('dropoff'),
                position: _ll(d.dropoff!),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(title: 'Mijoz', snippet: d.dropoffAddress),
              ),
            if (me != null && _courierIcon != null)
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
            if (route != null && _routePoints.length > 1 && !d.status.isTerminal) ...[
              // White casing under the route reads well on every map background.
              Polyline(polylineId: const PolylineId('route-casing'), points: _routePoints, color: Colors.white, width: 9),
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: Theme.of(context).colorScheme.primary,
                width: 5,
                zIndex: 1,
              ),
            ] else if (me != null && next != null && !d.status.isTerminal)
              Polyline(
                polylineId: const PolylineId('guide'),
                points: [me.position, _ll(next)],
                color: Theme.of(context).colorScheme.primary,
                width: 4,
                patterns: [PatternItem.dash(18), PatternItem.gap(10)],
              ),
          },
        );
      },
    );
  }
}

class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(trackingNotifierProvider.select((t) => t.isOnline));
    final show = !online && (delivery.status.isActive || delivery.status.isOffer);
    return AnimatedSwitcher(
      duration: AppMotion.standard,
      child: !show
          ? const SizedBox.shrink()
          : Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.location_off_outlined),
                title: const Text('Siz oflaynsiz'),
                subtitle: const Text("Joylashuvingiz ko'rinmayapti"),
                trailing: FilledButton(onPressed: () => TrackingActions.goOnline(context, ref), child: const Text('Onlayn')),
              ),
            ),
    );
  }
}

class _BottomPanel extends ConsumerWidget {
  const _BottomPanel({required this.delivery, required this.route, required this.busy, required this.onAction});

  static const estimatedHeight = 280.0;

  final Delivery delivery;
  final DeliveryRoute? route;
  final bool busy;
  final Future<void> Function(DeliveryAction action) onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final d = delivery;
    final toPickup = d.status.isOffer || d.status == DeliveryStatus.accepted;
    final next = d.nextStop;

    return Material(
      elevation: 12,
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.status.isTerminal ? 'Yetkazish yakunlangan' : (toPickup ? "Do'konga boring" : 'Mijozga yetkazing'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  DeliveryStatusBadge(status: d.status),
                ],
              ),
              if (route != null && !d.status.isTerminal) _EtaRow(route: route!),
              const SizedBox(height: 10),
              _Stop(
                icon: Icons.storefront_outlined,
                color: Colors.orange,
                title: d.storeName ?? "Do'kon",
                done: !toPickup,
              ),
              _Stop(
                icon: Icons.place_outlined,
                color: Colors.green,
                title: d.dropoffAddress ?? "Manzil ko'rsatilmagan",
                subtitle: d.customerName,
                done: d.status == DeliveryStatus.delivered,
                trailing: d.customerPhone == null
                    ? null
                    : IconButton.filledTonal(
                        tooltip: "Qo'ng'iroq",
                        onPressed: () => DeliveryActions.call(context, d.customerPhone),
                        icon: const Icon(Icons.call),
                      ),
              ),
              if (!d.status.isTerminal) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (next != null && !d.status.isOffer) ...[
                      OutlinedButton.icon(
                        onPressed: () => DeliveryActions.navigate(context, next),
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Navigator'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(child: _primary(context, ref)),
                  ],
                ),
                if (d.status == DeliveryStatus.pickedUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: busy ? null : () => _complete(context),
                      child: const Text('Topshirdim'),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _complete(BuildContext context) async {
    if (await DeliveryActions.confirmComplete(context, delivery)) await onAction(DeliveryAction.complete);
  }

  Widget _primary(BuildContext context, WidgetRef ref) {
    final (label, icon, run) = switch (delivery.status) {
      DeliveryStatus.pending || DeliveryStatus.assigned => (
          'Qabul qilish',
          Icons.check,
          () => DeliveryActions.accept(context, ref, delivery),
        ),
      DeliveryStatus.accepted => ('Buyurtmani oldim', Icons.shopping_bag_outlined, () => onAction(DeliveryAction.pickup)),
      DeliveryStatus.pickedUp => ('Yetib keldim', Icons.flag_outlined, () => onAction(DeliveryAction.arrive)),
      _ => ('Topshirdim', Icons.task_alt, () => _complete(context)),
    };
    return FilledButton.icon(
      onPressed: busy ? null : run,
      icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon),
      label: Text(label),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({required this.icon, required this.color, required this.title, this.subtitle, this.done = false, this.trailing});

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool done;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : icon, color: done ? muted : color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: done ? muted : null, decoration: done ? TextDecoration.lineThrough : null),
                ),
                if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// "Do'kongacha ~4 daq · Mijozgacha ~17 daq · 5,3 km" — real ETAs only when the route starts at
/// the courier's live position; otherwise just the distance.
class _EtaRow extends StatelessWidget {
  const _EtaRow({required this.route});

  final DeliveryRoute route;

  static String _minutes(Duration d) => '~${(d.inSeconds / 60).ceil()} daq';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final toStore = route.toPickup ? route.remaining(RouteStopKind.pickup, now) : null;
    final toCustomer = route.remaining(RouteStopKind.dropoff, now);
    final km = (route.stop(RouteStopKind.dropoff)?.distanceMeters ?? route.distanceMeters) / 1000;
    final parts = [
      if (toStore != null) "Do'kongacha ${_minutes(toStore)}",
      if (toCustomer != null) 'Mijozgacha ${_minutes(toCustomer)}',
      '${km.toStringAsFixed(1).replaceAll('.', ',')} km',
    ];
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              parts.join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).animate(key: ValueKey(route.computedAt)).fadeIn(duration: AppMotion.standard);
  }
}
