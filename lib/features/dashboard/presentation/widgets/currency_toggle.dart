import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// UZS and USD are two parallel, never-summed ledgers (see `CLAUDE.md`) — this
/// toggle is how every dashboard screen switches which one is on display,
/// never blending them into one figure.
class CurrencyToggle extends ConsumerWidget {
  const CurrencyToggle({this.onDark = false, super.key});

  /// Light-on-dark pills for the home hero card.
  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PillToggle<Currency>(
      values: const [Currency.uzs, Currency.usd],
      selected: ref.watch(selectedDashboardCurrencyProvider),
      label: (c) => c == Currency.uzs ? 'UZS' : 'USD',
      onDark: onDark,
      onChanged: (c) => ref.read(selectedDashboardCurrencyProvider.notifier).state = c,
    );
  }
}
