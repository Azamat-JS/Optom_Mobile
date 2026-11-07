import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/restaurant_pos/presentation/providers/restaurant_pos_providers.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

const _maxDishes = 3;

/// Tint of each table state — green free, amber busy, violet ready, blue served-and-unpaid.
Color posTableColor(PosTableState state) => switch (state) {
  PosTableState.free => const Color(0xFF16834F),
  PosTableState.open => const Color(0xFFD9822B),
  PosTableState.ready => const Color(0xFF7C4DDB),
  PosTableState.unpaid => const Color(0xFF2F6FD6),
};

String posTableStateLabel(BuildContext context, PosTableState state) => switch (state) {
  PosTableState.free => context.l10n.rposStateFree,
  PosTableState.open => context.l10n.rposStateOpen,
  PosTableState.ready => context.l10n.rposStateReady,
  PosTableState.unpaid => context.l10n.rposStateUnpaid,
};

/// "hozir" / "12 daq" / "1 soat 5 daq"; amber after 20 minutes, red after 40.
class ElapsedLabel extends StatelessWidget {
  const ElapsedLabel({required this.since, required this.now, super.key});

  final DateTime since;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final mins = elapsedMinutes(since, now);
    final text = mins < 1
        ? l10n.rposJustNow
        : mins < 60
        ? l10n.rposElapsedMin(mins)
        : l10n.rposElapsedHour(mins ~/ 60, mins % 60);
    final color = mins >= 40
        ? Theme.of(context).colorScheme.error
        : mins >= 20
        ? const Color(0xFFD9822B)
        : colors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 14, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// One table on the Kassa floor: name, state, the dishes, elapsed time, total and waiter.
class PosTableCard extends StatelessWidget {
  const PosTableCard({required this.view, required this.now, required this.onTap, super.key});

  final PosTableView view;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final state = view.state;
    final tint = posTableColor(state);
    final dishes = view.dishes;
    final waiter = view.orders.map((o) => o.waiter).firstWhere((w) => w != null, orElse: () => null);

    return Semantics(
      button: true,
      label: '${view.table.name}, ${posTableStateLabel(context, state)}',
      child: DashCard(
        onTap: onTap,
        outlineColor: state == PosTableState.free ? null : tint,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    view.table.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    posTableStateLabel(context, state),
                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (view.table.percent > 0)
              Text(
                l10n.rposServicePercent(_percent(view.table.percent)),
                style: TextStyle(color: colors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            if (state == PosTableState.free) ...[
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.add_rounded, size: 18, color: tint),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      l10n.rposTapToOrder,
                      style: TextStyle(color: tint, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ] else ...[
              if (state == PosTableState.ready || state == PosTableState.unpaid) ...[
                const SizedBox(height: 6),
                Text(
                  state == PosTableState.ready ? l10n.rposReadyToServe : l10n.rposTakePayment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: tint, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
              const SizedBox(height: 6),
              for (final (name, qty) in dishes.take(_maxDishes))
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '×$qty',
                      style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              if (dishes.length > _maxDishes)
                Text(
                  l10n.rposMoreItems(dishes.length - _maxDishes),
                  style: TextStyle(color: colors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              const Spacer(),
              Row(
                children: [
                  if (view.since != null) ElapsedLabel(since: view.since!, now: now),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.format(view.grandTotal, Currency.uzs),
                        style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                [
                  if (view.orders.length > 1) l10n.rposBills(view.orders.length),
                  waiter?.fullName ?? l10n.rposTakenAtCashier,
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _percent(double p) => p == p.truncateToDouble() ? p.toStringAsFixed(0) : p.toString();
