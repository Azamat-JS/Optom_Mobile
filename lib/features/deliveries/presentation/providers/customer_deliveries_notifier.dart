import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/deliveries/domain/entities/delivery.dart';
import 'package:bsmart/features/deliveries/domain/usecases/list_deliveries_usecase.dart';

/// "Yetkazishlarim" — every delivery the CUSTOMER may see: their storefront
/// orders (by buyer) plus restaurant deliveries staff entered for their
/// number, the latter only once the phone is verified (Phase 6 V5; the backend
/// decides). Active ones first. Re-fetched when the user's verification state
/// changes and every 30 s while the screen is open.
class CustomerDeliveriesNotifier extends AutoDisposeAsyncNotifier<List<Delivery>> {
  @override
  Future<List<Delivery>> build() async {
    // Verifying the phone on another screen unlocks restaurant deliveries — refetch then.
    ref.watch(sessionNotifierProvider.select((s) => s.valueOrNull?.user?.phoneVerified));
    final poll = Timer.periodic(const Duration(seconds: 30), (_) => refresh());
    ref.onDispose(poll.cancel);
    return _fetch();
  }

  Future<List<Delivery>> _fetch() async {
    final result = await getIt<ListDeliveriesUseCase>().call();
    final items = result.fold((list) => list, (failure) => throw failure);
    int rank(Delivery d) => d.status.isActive ? 0 : (d.status.isTerminal ? 2 : 1);
    return [...items]..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<void> refresh() async {
    final next = await AsyncValue.guard(_fetch);
    // Keep the previous list on a failed background refresh.
    if (next.hasError && state.hasValue) return;
    state = next;
  }
}

final customerDeliveriesProvider = AsyncNotifierProvider.autoDispose<CustomerDeliveriesNotifier, List<Delivery>>(
  CustomerDeliveriesNotifier.new,
);
