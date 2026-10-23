import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/location/location_tracker.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/map_overlay.dart';

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
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MapPinPickerScreen(title: title, initial: initial),
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.locationDetectFailed)));
      }
      return;
    }
    final target = LatLng(fix.lat, fix.lng);
    _center = target;
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    return Scaffold(
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
              padding: const EdgeInsets.only(bottom: _BrandPin.height),
              child: AnimatedSlide(
                offset: Offset(0, _dragging ? -0.2 : 0),
                duration: AppMotion.fast,
                curve: AppMotion.emphasized,
                child: const _BrandPin(),
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedContainer(
              duration: AppMotion.fast,
              width: _dragging ? 14 : 8,
              height: _dragging ? 6 : 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: _dragging ? 0.25 : 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: MapTopBar(title: widget.title)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 14),
                  child: MapRoundButton(
                    icon: Icons.my_location_rounded,
                    tooltip: l10n.locationMyLocation,
                    busy: _locating,
                    onTap: _goToMe,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colors.sheet,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16)],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.brandYellow.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.pan_tool_alt_rounded, color: colors.accentText, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.locationDragHint,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: _dragging
                                ? null
                                : () => Navigator.of(context).pop(GeoPoint(_center.latitude, _center.longitude)),
                            icon: const Icon(Icons.check_rounded),
                            label: Text(l10n.locationChooseHere),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ink head with a yellow centre on a short stem; the stem's end is the
/// chosen point.
class _BrandPin extends StatelessWidget {
  const _BrandPin();

  static const double height = 54;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(color: AppColors.brandYellow, shape: BoxShape.circle),
            ),
          ),
          Container(
            width: 4,
            height: 14,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
            ),
          ),
        ],
      ),
    );
  }
}
