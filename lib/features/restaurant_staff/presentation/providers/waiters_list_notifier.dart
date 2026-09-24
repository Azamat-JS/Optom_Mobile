import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/restaurant_staff/domain/entities/waiter.dart';
import 'package:bsmart/features/restaurant_staff/domain/usecases/list_waiters_usecase.dart';

class WaitersListState {
  const WaitersListState({required this.items, required this.waiterLimit});

  final List<Waiter> items;
  final int waiterLimit;
}

class WaitersListNotifier extends AsyncNotifier<WaitersListState> {
  @override
  Future<WaitersListState> build() => _fetch();

  Future<WaitersListState> _fetch() async {
    final result = await getIt<ListWaitersUseCase>().call();
    return result.fold(
      (page) => WaitersListState(items: page.items, waiterLimit: page.waiterLimit),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final waitersListProvider = AsyncNotifierProvider<WaitersListNotifier, WaitersListState>(
  WaitersListNotifier.new,
);
