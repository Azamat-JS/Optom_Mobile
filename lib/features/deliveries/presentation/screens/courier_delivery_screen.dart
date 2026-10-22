import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bsmart/core/location/location_fix.dart';
import 'package:bsmart/core/maps/animated_position.dart';
import 'package:bsmart/core/maps/map_icons.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/maps/polyline_codec.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery_route.dart';
import 'package:bsmart/features/deliveries/domain/repositories/deliveries_repository.dart';
import 'package:bsmart/features/deliveries/presentation/delivery_actions.dart';
import 'package:bsmart/features/deliveries/presentation/providers/delivery_detail_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/providers/delivery_route_notifier.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/courier_outcome_sheets.dart';
import 'package:bsmart/features/deliveries/presentation/widgets/delivery_status_badge.dart';
import 'package:bsmart/features/tracking/presentation/providers/tracking_notifier.dart';
import 'package:bsmart/features/tracking/presentation/tracking_actions.dart';
import 'package:bsmart/features/tracking/presentation/widgets/tracking_status_pill.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';
import 'package:bsmart/shared/widgets/map_overlay.dart';

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
  BitmapDescriptor? _shopIcon;
  BitmapDescriptor? _homeIcon;
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
    _fixes = tracking.fixes.listen(
      (f) => _courier.moveTo(LatLng(f.lat, f.lng), heading: (f.speed ?? 0) > 1 ? f.heading : null),
    );
    // Re-renders the ETA countdown between server updates.
    _tick = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
    // Same pins as the customer's tracking map (Phase 9 U3c).
    MapIcons.courier(AppColors.ink).then((icon) {
      if (mounted) setState(() => _courierIcon = icon);
    });
    MapIcons.pin(
      Icons.storefront_rounded,
      fill: AppColors.ink,
      ring: AppColors.brandYellow,
      glyphColor: AppColors.brandYellow,
    ).then((icon) => mounted ? setState(() => _shopIcon = icon) : null);
    MapIcons.pin(
      Icons.near_me_rounded,
      fill: AppColors.ink,
      ring: Colors.white,
      glyphColor: Colors.white,
    ).then((icon) => mounted ? setState(() => _homeIcon = icon) : null);
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
    if (action == DeliveryAction.complete) return _complete();
    setState(() => _busy = true);
    final failure = await ref.read(deliveryDetailProvider(widget.deliveryId).notifier).advance(action);
    if (!mounted) return;
    setState(() => _busy = false);
    if (failure != null) DeliveryActions.showError(context, failure.message);
  }

  /// With a pending handover code the code sheet does the completing (it shows tries left / locked
  /// / a staff waiver live); otherwise the usual confirm (Phase 7 N2).
  Future<void> _complete() async {
    final d = ref.read(deliveryDetailProvider(widget.deliveryId)).valueOrNull;
    if (d == null) return;
    bool done;
    if (d.handover.pending) {
      done = await HandoverCodeSheet.show(context, d.id);
    } else {
      if (!await DeliveryActions.confirmComplete(context, d) || !mounted) return;
      setState(() => _busy = true);
      final failure = await ref.read(deliveryDetailProvider(widget.deliveryId).notifier).complete();
      if (!mounted) return;
      setState(() => _busy = false);
      if (failure != null) {
        // The store may have just switched the code on — reopen as the code prompt.
        final fresh = ref.read(deliveryDetailProvider(widget.deliveryId)).valueOrNull;
        if (fresh != null && fresh.handover.pending && mounted) {
          done = await HandoverCodeSheet.show(context, fresh.id);
        } else {
          DeliveryActions.showError(context, failure.message);
          return;
        }
      } else {
        done = true;
      }
    }
    if (!done || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.dlvCompleted)));
    Navigator.of(context).pop();
  }

  Future<void> _fail() async {
    final choice = await FailDeliverySheet.show(context);
    if (choice == null || !mounted) return;
    setState(() => _busy = true);
    final failure = await ref.read(deliveryDetailProvider(widget.deliveryId).notifier).fail(choice.$1, note: choice.$2);
    if (!mounted) return;
    setState(() => _busy = false);
    if (failure != null) {
      DeliveryActions.showError(context, failure.message);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.dlvFailedMarked)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final delivery = ref.watch(deliveryDetailProvider(widget.deliveryId));
    final route = ref.watch(deliveryRouteProvider(widget.deliveryId)).valueOrNull;
    if (route != null && route.encodedPolyline != _decodedFor) {
      _decodedFor = route.encodedPolyline;
      _routePoints = decodePolyline(route.encodedPolyline);
    }
    final title = delivery.valueOrNull?.label ?? context.l10n.dlvLabelFallback;
    final d = delivery.valueOrNull;
    if (d != null && !_fitted && _map != null) {
      _fitted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll(d));
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: delivery.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => DashEmptyState(icon: Icons.cloud_off_rounded, text: context.l10n.commonErrorWith('$e')),
              data: (d) => _buildMap(d, route),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MapTopBar(
                  title: title,
                  actions: [
                    MapRoundButton(
                      icon: Icons.zoom_out_map_rounded,
                      tooltip: context.l10n.mapFitAll,
                      onTap: d == null ? null : () => _fitAll(d),
                    ),
                  ],
                ),
                if (d != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _OfflineBanner(delivery: d),
                  ),
              ],
            ),
          ),
          if (d != null) ...[
            Positioned(
              right: 16,
              bottom: 12 + _BottomPanel.estimatedHeight,
              child: MapRoundButton(
                icon: Icons.my_location_rounded,
                tooltip: context.l10n.mapMyLocation,
                onTap: () {
                  final me = _courier.value;
                  if (me != null) _map?.animateCamera(CameraUpdate.newLatLngZoom(me.position, 16));
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomPanel(delivery: d, route: route, busy: _busy, onAction: _run, onFail: _fail)
                  .animate()
                  .slideY(begin: 0.3, duration: AppMotion.standard, curve: AppMotion.emphasized)
                  .fadeIn(duration: AppMotion.standard),
            ),
          ],
        ],
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
          initialCameraPosition: CameraPosition(
            target: initial != null ? _ll(initial) : (me?.position ?? _tashkent),
            zoom: 13,
          ),
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
          // Top inset leaves room for the top bar + offline banner so fit-to-bounds never hides a
          // pin under them.
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 130, bottom: _BottomPanel.estimatedHeight),
          markers: {
            if (d.pickup != null)
              Marker(
                markerId: const MarkerId('pickup'),
                position: _ll(d.pickup!),
                icon: _shopIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                anchor: const Offset(0.5, 1),
                infoWindow: InfoWindow(title: context.l10n.dlvPickup, snippet: d.storeName),
              ),
            if (d.dropoff != null)
              Marker(
                markerId: const MarkerId('dropoff'),
                position: _ll(d.dropoff!),
                icon: _homeIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                anchor: const Offset(0.5, 1),
                infoWindow: InfoWindow(title: context.l10n.salesCustomer, snippet: d.dropoffAddress),
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
              Polyline(
                polylineId: const PolylineId('route-casing'),
                points: _routePoints,
                color: Colors.white,
                width: 9,
              ),
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: AppColors.ink,
                width: 5,
                zIndex: 1,
              ),
            ] else if (me != null && next != null && !d.status.isTerminal)
              Polyline(
                polylineId: const PolylineId('guide'),
                points: [me.position, _ll(next)],
                color: AppColors.ink,
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
    final theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: AppMotion.standard,
      // Online: the live sharing pill; offline: a prompt to go online.
      child: !show
          ? Align(alignment: Alignment.centerLeft, child: online ? const TrackingStatusPill() : const SizedBox.shrink())
          : Material(
              elevation: 3,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(20),
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                child: Row(
                  children: [
                    Icon(Icons.location_off_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.dlvYouAreOffline,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(context.l10n.dlvLocationHidden, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => TrackingActions.goOnline(context, ref),
                      child: Text(context.l10n.trkOnline),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BottomPanel extends ConsumerWidget {
  const _BottomPanel({
    required this.delivery,
    required this.route,
    required this.busy,
    required this.onAction,
    required this.onFail,
  });

  static const estimatedHeight = 280.0;

  final Delivery delivery;
  final DeliveryRoute? route;
  final bool busy;
  final Future<void> Function(DeliveryAction action) onAction;
  final Future<void> Function() onFail;

  static String _title(AppLocalizations l10n, Delivery d, bool toPickup) => switch (d.status) {
    DeliveryStatus.failed => l10n.dlvFailed,
    DeliveryStatus.cancelled => l10n.dlvCancelledTitle,
    _ when d.status.isTerminal => l10n.dlvFinishedTitle,
    _ => toPickup ? l10n.dlvGoToStore : l10n.dlvDeliverToCustomer,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = BrandColors.of(context);
    final d = delivery;
    final toPickup = d.status.isOffer || d.status == DeliveryStatus.accepted;
    final next = d.nextStop;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));

    return Material(
      elevation: 12,
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _title(context.l10n, d, toPickup),
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DeliveryStatusBadge(status: d.status),
                ],
              ),
              if (route != null && !d.status.isTerminal) _EtaRow(route: route!),
              if (d.status == DeliveryStatus.failed && d.failReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    [d.failReason!.label, if (d.failNote?.isNotEmpty ?? false) d.failNote!].join(' — '),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              if (d.handover.pending && d.status.isWithCourier)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.pin_rounded, size: 18, color: colors.accentText),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          d.handover.locked ? context.l10n.dlvCodeLockedHint : context.l10n.dlvAskCode,
                          style: TextStyle(color: colors.accentText, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                decoration: BoxDecoration(color: DashColors.inset(context), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _Stop(
                      icon: Icons.storefront_rounded,
                      title: d.storeName ?? context.l10n.dlvStoreFallback,
                      done: !toPickup,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 17),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(width: 2, height: 10, color: colors.outline),
                      ),
                    ),
                    _Stop(
                      icon: Icons.near_me_rounded,
                      highlight: true,
                      title: d.dropoffAddress ?? context.l10n.dlvNoAddress,
                      subtitle: d.customerName,
                      done: d.status == DeliveryStatus.delivered,
                      trailing: d.customerPhone == null
                          ? null
                          : MapCallButton(onPressed: () => DeliveryActions.call(context, d.customerPhone)),
                    ),
                  ],
                ),
              ),
              if (!d.status.isTerminal) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (next != null && !d.status.isOffer) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56), shape: shape),
                        onPressed: () => DeliveryActions.navigate(context, next),
                        icon: const Icon(Icons.navigation_rounded),
                        label: Text(context.l10n.dlvNavigator),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(child: _primary(context, ref)),
                  ],
                ),
                if (d.status.isWithCourier)
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        onPressed: busy ? null : onFail,
                        icon: const Icon(Icons.report_rounded, size: 18),
                        label: Text(context.l10n.dlvFailed),
                      ),
                      const Spacer(),
                      if (d.status == DeliveryStatus.pickedUp)
                        TextButton(
                          onPressed: busy ? null : () => onAction(DeliveryAction.complete),
                          child: Text(context.l10n.dlvHandedOver),
                        ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _primary(BuildContext context, WidgetRef ref) {
    final (label, icon, run) = switch (delivery.status) {
      DeliveryStatus.pending || DeliveryStatus.assigned => (
        context.l10n.restAccept,
        Icons.check_rounded,
        () => DeliveryActions.accept(context, ref, delivery),
      ),
      DeliveryStatus.accepted => (
        context.l10n.dlvPickedUp,
        Icons.shopping_bag_outlined,
        () => onAction(DeliveryAction.pickup),
      ),
      DeliveryStatus.pickedUp => (context.l10n.dlvArrived, Icons.flag_outlined, () => onAction(DeliveryAction.arrive)),
      _ => (context.l10n.dlvHandedOver, Icons.task_alt, () => onAction(DeliveryAction.complete)),
    };
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: busy ? null : run,
      icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon),
      label: Text(label),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.icon,
    required this.title,
    this.subtitle,
    this.done = false,
    this.highlight = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool done;

  /// The customer's stop: yellow circle (the store's is ink).
  final bool highlight;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: done ? colors.outline : (highlight ? AppColors.brandYellow : AppColors.ink),
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            size: 19,
            color: done ? colors.textMuted : (highlight ? AppColors.onBrand : AppColors.brandYellow),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: done ? colors.textMuted : colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// "Do'kongacha ~4 daq · Mijozgacha ~17 daq · 5,3 km" — real ETAs only when the route starts at
/// the courier's live position; otherwise just the distance.
class _EtaRow extends StatelessWidget {
  const _EtaRow({required this.route});

  final DeliveryRoute route;

  static String _minutes(AppLocalizations l10n, Duration d) => l10n.dlvMinutesShort('${(d.inSeconds / 60).ceil()}');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final toStore = route.toPickup ? route.remaining(RouteStopKind.pickup, now) : null;
    final toCustomer = route.remaining(RouteStopKind.dropoff, now);
    final km = (route.stop(RouteStopKind.dropoff)?.distanceMeters ?? route.distanceMeters) / 1000;
    final parts = [
      if (toStore != null) l10n.dlvToStore(_minutes(l10n, toStore)),
      if (toCustomer != null) l10n.dlvToCustomer(_minutes(l10n, toCustomer)),
      l10n.commonKm(km.toStringAsFixed(1).replaceAll('.', ',')),
    ];
    const green = AppColors.success;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded, size: 17, color: green),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                parts.join(' · '),
                style: const TextStyle(color: green, fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    ).animate(key: ValueKey(route.computedAt)).fadeIn(duration: AppMotion.standard);
  }
}
