import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/location/location_tracker.dart';
import 'package:bsmart/core/theme/app_motion.dart';

/// Full-screen "drag the map under a fixed pin" location picker. Resolves to
/// the chosen [GeoPoint], or null if the user backs out.
///
/// Used for delivery drop-off pins (storefront checkout, restaurant delivery
/// orders) and a store's pickup point.
class MapPinPickerScreen extends StatefulWidget {
  const MapPinPickerScreen({super.key, required this.title, this.initial});

  final String title;
  final GeoPoint? initial;

  static Future<GeoPoint?> pick(BuildContext context, {required String title, GeoPoint? initial}) {
    return Navigator.of(context).push<GeoPoint>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => MapPinPickerScreen(title: title, initial: initial)),
    );
  }

  @override
  State<MapPinPickerScreen> createState() => _MapPinPickerScreenState();
}

class _MapPinPickerScreenState extends State<MapPinPickerScreen> {
  static const _tashkent = LatLng(41.3111, 69.2797);

  GoogleMapController? _map;
  late LatLng _center = widget.initial != null ? LatLng(widget.initial!.lat, widget.initial!.lng) : _tashkent;
  bool _dragging = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    // No saved pin yet → start from where the user is (if they allow it).
    if (widget.initial == null) _goToMe(silent: true);
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  Future<void> _goToMe({bool silent = false}) async {
    setState(() => _locating = true);
    final fix = await getIt<LocationTracker>().currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (fix == null) {
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Joylashuvni aniqlab bo'lmadi — GPS va ruxsatni tekshiring")),
        );
      }
      return;
    }
    final target = LatLng(fix.lat, fix.lng);
    _center = target;
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: widget.initial != null ? 17 : 13),
            onMapCreated: (c) => _map = c,
            onCameraMoveStarted: () => setState(() => _dragging = true),
            onCameraMove: (p) => _center = p.target,
            onCameraIdle: () => setState(() => _dragging = false),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          // The pin's tip sits exactly on the map centre; it lifts while dragging.
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: AnimatedSlide(
                offset: Offset(0, _dragging ? -0.25 : 0),
                duration: AppMotion.fast,
                curve: AppMotion.emphasized,
                child: Icon(Icons.location_on, size: 48, color: theme.colorScheme.primary),
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _dragging ? 1 : 0.6,
              duration: AppMotion.fast,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 104,
            child: FloatingActionButton.small(
              heroTag: 'pin-me',
              tooltip: 'Mening joylashuvim',
              onPressed: _locating ? null : _goToMe,
              child: _locating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: _dragging
                    ? null
                    : () => Navigator.of(context).pop(GeoPoint(_center.latitude, _center.longitude)),
                icon: const Icon(Icons.check),
                label: const Text('Shu joyni tanlash'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
