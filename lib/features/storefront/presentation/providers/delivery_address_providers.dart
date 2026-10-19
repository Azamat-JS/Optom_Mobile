import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bsmart/core/entities/geo_point.dart';

/// A delivery address the customer used before: the text the shop and the
/// courier read, plus the optional map pin (`deliveryLat/deliveryLng`).
class SavedAddress {
  const SavedAddress({required this.text, this.point});

  final String text;
  final GeoPoint? point;

  /// First part of the address ("Amir Temur ko'chasi 12"), the rest goes to
  /// a second line.
  String get title => text.split(',').first.trim();

  String get rest {
    final i = text.indexOf(',');
    return i < 0 ? '' : text.substring(i + 1).trim();
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    if (point != null) 'lat': point!.lat,
    if (point != null) 'lng': point!.lng,
  };

  static SavedAddress? fromJson(Object? json) {
    if (json is! Map) return null;
    final text = json['text'];
    if (text is! String || text.trim().isEmpty) return null;
    final lat = json['lat'];
    final lng = json['lng'];
    return SavedAddress(text: text, point: lat is num && lng is num ? GeoPoint(lat.toDouble(), lng.toDouble()) : null);
  }

  bool sameAs(SavedAddress other) => text.trim().toLowerCase() == other.text.trim().toLowerCase();
}

/// Addresses used on this device, newest first (SharedPreferences, like
/// recent searches; not tied to an account — the backend has no address
/// book).
class SavedAddressesNotifier extends AsyncNotifier<List<SavedAddress>> {
  static const _key = 'bsmart.storefront.savedAddresses';
  static const maxEntries = 6;

  @override
  Future<List<SavedAddress>> build() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List).map(SavedAddress.fromJson).whereType<SavedAddress>().toList();
    } on FormatException {
      return const [];
    }
  }

  /// Moves [address] to the front (same text = same address), capped.
  Future<void> remember(SavedAddress address) async {
    final current = await future;
    final next = [address, ...current.where((a) => !a.sameAs(address))].take(maxEntries).toList();
    state = AsyncData(next);
    await _save(next);
  }

  Future<void> remove(SavedAddress address) async {
    final next = (await future).where((a) => !a.sameAs(address)).toList();
    state = AsyncData(next);
    await _save(next);
  }

  Future<void> _save(List<SavedAddress> list) async =>
      (await SharedPreferences.getInstance()).setString(_key, jsonEncode(list.map((a) => a.toJson()).toList()));
}

final savedAddressesProvider = AsyncNotifierProvider<SavedAddressesNotifier, List<SavedAddress>>(
  SavedAddressesNotifier.new,
);

/// How the current checkout is delivered: to an address, or picked up.
sealed class DeliveryChoice {
  const DeliveryChoice();
}

class DeliverTo extends DeliveryChoice {
  const DeliverTo(this.address);

  final SavedAddress address;
}

class PickUp extends DeliveryChoice {
  const PickUp();
}

/// The checkout's delivery choice. Starts empty (→ "Qayerga yetkazamiz?"),
/// or on the most recently used address once those have loaded.
class CheckoutDeliveryNotifier extends Notifier<DeliveryChoice?> {
  bool _touched = false;

  @override
  DeliveryChoice? build() {
    final recent = ref.watch(savedAddressesProvider).valueOrNull;
    if (_touched) return stateOrNull;
    return recent == null || recent.isEmpty ? null : DeliverTo(recent.first);
  }

  void choose(DeliveryChoice? choice) {
    _touched = true;
    state = choice;
  }
}

final checkoutDeliveryProvider = NotifierProvider<CheckoutDeliveryNotifier, DeliveryChoice?>(
  CheckoutDeliveryNotifier.new,
);
