import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/reports/domain/entities/work_day.dart';
import 'package:bsmart/features/reports/domain/usecases/end_work_day_usecase.dart';
import 'package:bsmart/features/reports/domain/usecases/get_current_work_day_usecase.dart';
import 'package:bsmart/features/reports/domain/usecases/start_work_day_usecase.dart';

/// The current shift — `null` before any shift has ever been started for
/// this tenant, `WorkDay.status == open/closed` afterward (see
/// `WorkDayService.getCurrent`: open if one is running, else the most
/// recently closed one, so the "Kun tahlili" summary stays visible right
/// after ending a shift instead of blanking out).
class WorkDayNotifier extends AsyncNotifier<WorkDay?> {
  @override
  Future<WorkDay?> build() async {
    final result = await getIt<GetCurrentWorkDayUseCase>().call();
    return result.fold((d) => d, (failure) => throw failure);
  }

  Future<void> start() async {
    final result = await getIt<StartWorkDayUseCase>().call();
    result.fold((workDay) => state = AsyncData(workDay), (failure) => throw failure);
  }

  Future<void> end() async {
    final result = await getIt<EndWorkDayUseCase>().call();
    result.fold((workDay) => state = AsyncData(workDay), (failure) => throw failure);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final workDayProvider = AsyncNotifierProvider<WorkDayNotifier, WorkDay?>(WorkDayNotifier.new);
