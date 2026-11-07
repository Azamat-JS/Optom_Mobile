import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/ingredient_unit.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

final _qty3 = NumberFormat('#,##0.###', 'uz');
final _qty2 = NumberFormat('#,##0.##', 'uz');

/// "1,25 kg", "150 g", "3 dona" — up to 3 decimals (grams of a kg), no trailing zeros.
String formatIngredientQty(double value, IngredientUnit unit) =>
    '${(unit.isCount ? _qty2 : _qty3).format(value)} ${unit.shortLabel}';

/// So'm, rounded to whole so'm (averages leave fractions nobody pays).
String formatSom(double value) => CurrencyFormatter.format(value.roundToDouble(), Currency.uzs);

const warehouseGreen = Color(0xFF15803D);
const warehouseAmber = Color(0xFFB45309);

Color levelColor(BuildContext context, IngredientLevel level) => switch (level) {
  IngredientLevel.ok => warehouseGreen,
  IngredientLevel.low => warehouseAmber,
  IngredientLevel.out => Theme.of(context).colorScheme.error,
};

String levelLabel(BuildContext context, IngredientLevel level) => switch (level) {
  IngredientLevel.ok => context.l10n.whLevelOk,
  IngredientLevel.low => context.l10n.whLevelLow,
  IngredientLevel.out => context.l10n.whLevelOut,
};

class IngredientLevelTag extends StatelessWidget {
  const IngredientLevelTag({required this.level, super.key});

  final IngredientLevel level;

  @override
  Widget build(BuildContext context) => DashTag(label: levelLabel(context, level), color: levelColor(context, level));
}

Color dishStatusColor(BuildContext context, DishStatus status) => switch (status) {
  DishStatus.ok => warehouseGreen,
  DishStatus.low => warehouseAmber,
  DishStatus.unavailable => Theme.of(context).colorScheme.error,
  DishStatus.noRecipe => Theme.of(context).colorScheme.outline,
};

/// "12 porsiya" / "3 porsiya qoldi" / "Masalliq yetmaydi". Nothing for a dish without a recipe.
class DishAvailabilityTag extends StatelessWidget {
  const DishAvailabilityTag({required this.status, this.portions, super.key});

  final DishStatus status;
  final int? portions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (status == DishStatus.noRecipe) return const SizedBox.shrink();
    final label = switch (status) {
      DishStatus.unavailable => l10n.whDishUnavailable,
      _ when portions == null => l10n.whDishOk,
      DishStatus.low => l10n.whDishLowPortions(portions!),
      _ => l10n.whPortions(portions!),
    };
    return DashTag(label: label, color: dishStatusColor(context, status));
  }
}

/// A failed warehouse request as text: 403 = not a restaurant owner/admin (or switched account).
String warehouseErrorText(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is ForbiddenApiException) return l10n.whForbidden;
  return l10n.commonErrorWith(error is ApiException ? error.message : '$error');
}
