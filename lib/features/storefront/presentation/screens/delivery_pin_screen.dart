import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/entities/geo_point.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/location/location_tracker.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/storefront/presentation/providers/delivery_address_providers.dart';

/// Checkout's "drag the map under the pin" step (Phase 9 U3b, the reference's
/// map + "Order will be delivered here" card). The address field is filled
/// from the pin by the phone's own geocoder until the customer edits it.
/// Pops a [SavedAddress], or null when backed out.
class DeliveryPinScreen extends StatefulWidget {
  const DeliveryPinScreen({this.initial, this.locateOnStart = true, super.key});

  final SavedAddress? initial;

  /// Start on the device's position when there's no [initial] pin.
  final bool locateOnStart;

  static Future<SavedAddress?> open(BuildContext context, {SavedAddress? initial, bool locateOnStart = true}) {
    return Navigator.of(context).push<SavedAddress>(
      MaterialPageRoute(
        builder: (_) => DeliveryPinScreen(initial: initial, locateOnStart: locateOnStart),
      ),
    );
  }

  @override
  State<DeliveryPinScreen> createState() => _DeliveryPinScreenState();
}

class _DeliveryPinScreenState extends State<DeliveryPinScreen> {
  static const _tashkent = LatLng(41.3111, 69.2797);
  static const _geocoderLocale = {'uz': 'uz_UZ', 'ru': 'ru_RU', 'en': 'en_US'};

  GoogleMapController? _map;
  late LatLng _center = widget.initial?.point != null
      ? LatLng(widget.initial!.point!.lat, widget.initial!.point!.lng)
      : _tashkent;
  late final _address = TextEditingController(text: widget.initial?.text ?? '');

  /// Once the customer types, the pin no longer overwrites the text.
  bool _edited = false;
  bool _dragging = false;
  bool _locating = false;
  bool _geocoding = false;
  int _geocodeRun = 0;

  @override
  void initState() {
    super.initState();
    _edited = widget.initial != null;
    if (widget.initial?.point == null && widget.locateOnStart) _goToMe(silent: true);
  }

  @override
  void dispose() {
    _map?.dispose();
    _address.dispose();
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
    _center = LatLng(fix.lat, fix.lng);
    await _map?.animateCamera(CameraUpdate.newLatLngZoom(_center, 17));
    _reverseGeocode();
  }

  /// Fills the address field from the pin (skipped once edited; a newer pin
  /// position wins over a slower older lookup).
  Future<void> _reverseGeocode() async {
    if (_edited) return;
    final run = ++_geocodeRun;
    setState(() => _geocoding = true);
    String? text;
    try {
      // Street names in the app's language where the geocoder has them.
      await geo.setLocaleIdentifier(_geocoderLocale[Localizations.localeOf(context).languageCode] ?? 'uz_UZ');
      final marks = await geo.placemarkFromCoordinates(_center.latitude, _center.longitude);
      if (marks.isNotEmpty) text = formatPlacemark(marks.first);
    } on Exception {
      // No network, no result, or the platform geocoder is unavailable: the
      // customer types the address.
      text = null;
    }
    if (!mounted || run != _geocodeRun) return;
    setState(() => _geocoding = false);
    if (!_edited && text != null && text.isNotEmpty) _address.text = text;
  }

  void _confirm() {
    final text = _address.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(SavedAddress(text: text, point: GeoPoint(_center.latitude, _center.longitude)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Theme(
      data: BrandTheme.of(context),
      child: Builder(
        builder: (context) {
          final colors = BrandColors.of(context);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: widget.initial?.point != null ? 17 : 13,
                          ),
                          onMapCreated: (c) => _map = c,
                          onCameraMoveStarted: () => setState(() => _dragging = true),
                          onCameraMove: (p) => _center = p.target,
                          onCameraIdle: () {
                            setState(() => _dragging = false);
                            _reverseGeocode();
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                        ),
                        // Pin tip on the map centre; lifts while dragging.
                        IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 56),
                            child: AnimatedSlide(
                              offset: Offset(0, _dragging ? -0.2 : 0),
                              duration: AppMotion.fast,
                              curve: AppMotion.emphasized,
                              child: const _Pin(),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: Container(
                            width: 10,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: _dragging ? 0.18 : 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Row(
                                children: [
                                  _RoundButton(
                                    icon: Icons.arrow_back_rounded,
                                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                                    onTap: () => Navigator.of(context).maybePop(),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.symmetric(horizontal: 18),
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        color: colors.sheet,
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12)],
                                      ),
                                      child: Text(
                                        l10n.addrPickOnMap,
                                        style: TextStyle(
                                          color: colors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: _RoundButton(
                            icon: Icons.my_location_rounded,
                            tooltip: l10n.locationMyLocation,
                            busy: _locating,
                            onTap: _locating ? null : _goToMe,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.sheet,
                      boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 18, offset: Offset(0, -4))],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            color: colors.field,
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                            child: Text(
                              l10n.addrDeliveredHere,
                              style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextField(
                                  controller: _address,
                                  minLines: 1,
                                  maxLines: 3,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) {
                                    _edited = true;
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    labelText: l10n.addrFieldLabel,
                                    prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.brandAmber),
                                    suffixIcon: _geocoding
                                        ? const Padding(
                                            padding: EdgeInsets.all(14),
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          )
                                        : null,
                                    helperText: _geocoding ? l10n.addrDetecting : null,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: _dragging || _address.text.trim().isEmpty ? null : _confirm,
                                  child: Text(l10n.addrConfirm),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "Amir Temur ko'chasi 12, Yunusobod, Toshkent" from a placemark: street
/// first, then district and city, without empty or repeated parts.
String formatPlacemark(geo.Placemark p) {
  final street = [p.thoroughfare, p.subThoroughfare].where((s) => s != null && s.trim().isNotEmpty).join(' ');
  final parts = <String>[];
  for (final part in [street.isEmpty ? p.name : street, p.subLocality, p.locality ?? p.subAdministrativeArea]) {
    final value = part?.trim() ?? '';
    if (value.isEmpty || parts.any((existing) => existing.toLowerCase() == value.toLowerCase())) continue;
    parts.add(value);
  }
  return parts.join(', ');
}

class _Pin extends StatelessWidget {
  const _Pin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 4))],
            border: Border.all(color: AppColors.brandYellow, width: 3),
          ),
          child: const Center(child: CircleAvatar(radius: 8, backgroundColor: AppColors.brandYellow)),
        ),
        Container(width: 3, height: 14, color: AppColors.ink),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onTap, this.busy = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Material(
      color: colors.sheet,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Center(
              child: busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(icon, color: colors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
