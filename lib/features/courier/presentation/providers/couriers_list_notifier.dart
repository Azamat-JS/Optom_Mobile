import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/courier/domain/entities/courier.dart';
import 'package:bsmart/features/courier/domain/usecases/list_couriers_usecase.dart';

class CouriersListState {
  const CouriersListState({required this.items, required this.courierLimit});

  final List<Courier> items;
  final int courierLimit;
}

class CouriersListNotifier extends AsyncNotifier<CouriersListState> {
  @override
  Future<CouriersListState> build() => _fetch();

  Future<CouriersListState> _fetch() async {
    final result = await getIt<ListCouriersUseCase>().call();
    return result.fold(
      (page) => CouriersListState(items: page.items, courierLimit: page.courierLimit),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final couriersListProvider = AsyncNotifierProvider<CouriersListNotifier, CouriersListState>(
  CouriersListNotifier.new,
);
