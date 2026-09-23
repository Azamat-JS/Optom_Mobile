import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/debts/domain/entities/debt.dart';
import 'package:bsmart/features/debts/domain/entities/debt_query.dart';
import 'package:bsmart/features/debts/domain/usecases/list_debts_usecase.dart';

/// The B2B `Debt` list — a flat fetch (limit 500, matching `DebtQueryDto`'s
/// own max) grouped client-side by debtor/currency in the screen, not here.
/// [role] toggles a RETAILER between "debts I owe" (debtor) and "debts owed
/// to me" (creditor); a SELLER always sees the server's creditor-only default
/// (see `CLAUDE.md`'s "Customers / POS" note on why no debtor toggle is
/// exposed for SELLER in v1).
class DebtsListNotifier extends AsyncNotifier<List<Debt>> {
  String? _role;

  @override
  Future<List<Debt>> build() => _fetch();

  Future<List<Debt>> _fetch() async {
    final result = await getIt<ListDebtsUseCase>().call(DebtQuery(role: _role));
    return result.fold((page) => page.data, (failure) => throw failure);
  }

  Future<void> setRole(String? role) async {
    _role = role;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }
}

final debtsListProvider = AsyncNotifierProvider<DebtsListNotifier, List<Debt>>(DebtsListNotifier.new);
