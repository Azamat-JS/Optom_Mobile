import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/entities/debt_query.dart';
import 'package:bsmart/features/debts/domain/usecases/list_sale_debts_usecase.dart';

class SaleDebtsListNotifier extends AsyncNotifier<List<SaleDebt>> {
  @override
  Future<List<SaleDebt>> build() => _fetch();

  Future<List<SaleDebt>> _fetch() async {
    final result = await getIt<ListSaleDebtsUseCase>().call(const SaleDebtQuery());
    return result.fold((page) => page.data, (failure) => throw failure);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final saleDebtsListProvider = AsyncNotifierProvider<SaleDebtsListNotifier, List<SaleDebt>>(
  SaleDebtsListNotifier.new,
);
